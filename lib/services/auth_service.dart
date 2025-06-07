import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/user.dart';
import '../utils/firebase_error_utils.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  Future<User?> _userFromFirebase(firebase_auth.User? user) async {
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists ? User.fromMap(userDoc.data()!) : null;
  }

  Future<User?> get currentUser async {
    final user = _auth.currentUser;
    return user != null ? await _userFromFirebase(user) : null;
  }

  /// Atualiza os campos de perfil do usuário logado.
  Future<void> updateProfile({
    required String name,
    String? phone,
    String? occupation,
    String? description,
  }) async {
    final current = _auth.currentUser;
    if (current == null) {
      throw 'Usuário não autenticado.';
    }
    await _firestore.collection('users').doc(current.uid).update({
      'name': name,
      'phone': phone,
      'occupation': occupation,
      'description': description,
    });
  }

  Future<String> deleteUserAccount({
    required String targetUserId,
    String? currentUserPassword,
    required bool isLeader,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      // Carrega dados do alvo para validar permissão
      final targetDoc =
          await _firestore.collection('users').doc(targetUserId).get();
      if (!targetDoc.exists) throw 'Usuário não encontrado.';
      final targetRole = targetDoc.data()?['role'] as String?;

      // Impede que qualquer um, exceto o próprio master, exclua o master
      if (targetRole == 'Master') {
        if (currentUser == null || currentUser.uid != targetUserId) {
          throw 'Você não tem permissão para excluir o Master.';
        }
      }

      // Exclusão de conta própria
      if (currentUser != null && currentUser.uid == targetUserId) {
        // Exclui dados do Firestore
        await _firestore.collection('users').doc(targetUserId).delete();

        // Reautentica e exclui no Auth
        if (currentUserPassword == null) {
          throw 'Para excluir sua própria conta, forneça sua senha.';
        }
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: currentUser.email!,
          password: currentUserPassword,
        );
        await currentUser.reauthenticateWithCredential(credential);
        await currentUser.delete();
        return 'Conta excluída com sucesso!';
      }

      // Exclusão por líder (exceto master já tratado acima)
      if (isLeader) {
        final callable = _functions.httpsCallable('adminDeleteUser');
        final result = await callable.call({'userId': targetUserId});
        return result.data['message'] as String;
      }

      // Demais casos sem permissão
      throw 'Apenas líderes podem excluir outros usuários.';
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro ao excluir usuário: $e';
    }
  }

  String _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return 'Reautenticação necessária. Por favor, faça login novamente.';
      case 'permission-denied':
        return 'Permissões insuficientes.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }

  Stream<User?> get user =>
      _auth.authStateChanges().asyncMap(_userFromFirebase);

  Future<User?> login(String email, String password) async {
    try {
      final uc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebase(uc.user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      final msg = FirebaseErrorTranslator.translate(e.code);
      throw 'Erro ao fazer login: $msg';
    } catch (e) {
      throw 'Erro inesperado ao fazer login: $e';
    }
  }

  Future<User?> register(
    String email,
    String password, {
    required String name,
    required String role,
    required List<String> groupIds,
  }) async {
    try {
      final current = _auth.currentUser;
      late final String newUserId;

      if (current != null &&
          (role == 'Voluntário' || role == 'Líder' || role == 'Master')) {
        final callable = _functions.httpsCallable('adminCreateUser');
        final res = await callable.call({
          'email': email,
          'password': password,
          'displayName': name,
          'role': role,
        });
        newUserId = res.data['uid'] as String;

        await _firestore.collection('users').doc(newUserId).set({
          'id': newUserId,
          'name': name,
          'email': email,
          'role': role,
          'groupIds': groupIds,
        });
      } else {
        final uc = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        newUserId = uc.user!.uid;

        await _firestore.collection('users').doc(newUserId).set({
          'id': newUserId,
          'name': name,
          'email': email,
          'role': role,
          'groupIds': groupIds,
        });
      }

      final batch = _firestore.batch();
      if (role == 'Voluntário') {
        for (final groupId in groupIds) {
          final groupRef = _firestore.collection('groups').doc(groupId);
          batch.update(groupRef, {
            'userIds': FieldValue.arrayUnion([newUserId]),
          });
        }
      }

      batch.update(_firestore.collection('users').doc(newUserId), {
        'groupIds': groupIds,
      });
      await batch.commit();

      final newUserDoc =
          await _firestore.collection('users').doc(newUserId).get();
      return newUserDoc.exists ? User.fromMap(newUserDoc.data()!) : null;
    } on FirebaseFunctionsException catch (e) {
      final msg = FirebaseErrorTranslator.translate(e.code);
      throw 'Erro ao cadastrar: $msg';
    } on firebase_auth.FirebaseAuthException catch (e) {
      final msg = FirebaseErrorTranslator.translate(e.code);
      throw 'Erro ao cadastrar: $msg';
    } catch (e) {
      throw 'Erro inesperado ao cadastrar: $e';
    }
  }

  Future<void> logout() async => _auth.signOut();

  Stream<List<User>> getUsers() {
    return _firestore.collection('users').snapshots().map((snap) {
      try {
        return snap.docs.map((doc) => User.fromMap(doc.data())).toList();
      } catch (e) {
        print('❌ Erro ao processar usuários do snapshot: $e');
        return [];
      }
    });
  }

  Future<List<User>> getAllVolunteers() async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where('role', isEqualTo: 'Voluntário')
              .get();

      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    } catch (e) {
      print('❌ Erro ao buscar voluntários: $e');
      return [];
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    } catch (e) {
      print('❌ Erro ao buscar todos os usuários: $e');
      return [];
    }
  }

  //ajuste de alteração de senha
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('Usuário não autenticado');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<List<User>> getUsersInGroup(String groupId) async {
    final snapshot =
        await _firestore
            .collection('users')
            .where('groupIds', arrayContains: groupId)
            .get();

    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Stream<List<User>> getUsersInGroupStream(String groupId) {
    return _firestore
        .collection('users')
        .where('groupIds', arrayContains: groupId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) => User.fromMap(doc.data())).toList(),
        );
  }
}
