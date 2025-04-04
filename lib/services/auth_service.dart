import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<User?> _userFromFirebase(firebase_auth.User? user) async {
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists ? User.fromMap(userDoc.data()!) : null;
  }

  Future<User?> get currentUser async {
    final user = _auth.currentUser;
    return user != null ? await _userFromFirebase(user) : null;
  }

  Future<String> deleteUserAccount({
    required String targetUserId,
    String? currentUserPassword,
    required bool isLeader,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      await _firestore.collection('users').doc(targetUserId).delete();

      if (currentUser != null && currentUser.uid == targetUserId) {
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
      } else if (isLeader) {
        final callable = _functions.httpsCallable('adminDeleteUser');
        final result = await callable.call({'userId': targetUserId});
        return result.data['message'] as String;
      } else {
        throw 'Apenas líderes podem excluir outros usuários.';
      }
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

  Stream<User?> get user => _auth.authStateChanges().asyncMap(_userFromFirebase);

  Future<User?> login(String email, String password) async {
    final uc = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return await _userFromFirebase(uc.user);
  }

  Future<User?> register(String email, String password, String name, String role) async {
    final uc = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestore.collection('users').doc(uc.user!.uid).set({
      'id': uc.user!.uid,
      'name': name,
      'email': email,
      'role': role,
      'groupIds': [],
    });
    return await _userFromFirebase(uc.user);
  }

  Future<void> logout() async => _auth.signOut();

  Stream<List<User>> getUsers() => _firestore.collection('users').snapshots().map(
        (snap) => snap.docs.map((doc) => User.fromMap(doc.data())).toList(),
      );
}
