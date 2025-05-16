
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

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
      final targetDoc = await _firestore.collection('users').doc(targetUserId).get();
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
    final uc = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return await _userFromFirebase(uc.user);
  }

  Future<User?> register(
  String email,
  String password, {
  required String name,
  required String role,
  required List<String> groupIds,
}) async {
  final uc = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  final newUserId = uc.user!.uid;

  // 1. Grava o perfil no Firestore
  await _firestore.collection('users').doc(newUserId).set({
    'id': newUserId,
    'name': name,
    'email': email,
    'role': role,
    'groupIds': groupIds,
  });

  // 2. Adiciona o novo usuário aos grupos selecionados
  final batch = _firestore.batch();
  for (final groupId in groupIds) {
    final groupRef = _firestore.collection('groups').doc(groupId);
    batch.update(groupRef, {
      'userIds': FieldValue.arrayUnion([newUserId])
    });
  }
  await batch.commit();

  return await _userFromFirebase(uc.user);
}


  Future<void> logout() async => _auth.signOut();

  Stream<List<User>> getUsers() {
    return _firestore.collection('users').snapshots().map(
      (snap) {
        try {
          return snap.docs.map((doc) => User.fromMap(doc.data())).toList();
        } catch (e) {
          print('❌ Erro ao processar usuários do snapshot: $e');
          return [];
        }
      },
    );
  }

  Future<List<User>> getAllVolunteers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'Voluntário')
          .get();

      return snapshot.docs
          .map((doc) => User.fromMap(doc.data()))
          .toList();
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
}

