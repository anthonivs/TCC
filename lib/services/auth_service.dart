import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> _userFromFirebase(firebase_auth.User? user) async {
    if (user == null) return null;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      return User.fromMap(userDoc.data()!); 
    } else {
      return null;
    }
  }

  Future<User?> get currentUser async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _userFromFirebase(user);
  }

  Stream<User?> get user {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _userFromFirebase(user);
    });
  }

  Future<User?> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _userFromFirebase(userCredential.user);
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<User?> register(String email, String password, String name, String role) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid, 
        'name': name,
        'email': email,
        'role': role,
        'groupIds': [],
      });

      return await _userFromFirebase(userCredential.user);
    } on firebase_auth.FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        throw 'Este e-mail já está cadastrado.';
      } else {
        throw 'Erro ao cadastrar: ${e.message}';
      }
    } catch (e) {
      // Captura outros erros
      throw 'Erro ao cadastrar: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // Remove um usuário
  Future<void> removeUser(User user) async {
    await _firestore.collection('users').doc(user.id).delete();
  }

  Stream<List<User>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
    });
  }
}