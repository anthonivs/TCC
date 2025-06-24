/*import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import '../utils/firebase_error_utils.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'us-central1',
  );

  Future<void> _saveFcmTokenToFirestore(String userId) async {
    try {
      if (!Platform.isAndroid) {
        print('📱 Ignorando FCM: plataforma iOS sem APNs configurado.');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
        print('Token FCM salvo com sucesso: $token');
      }
    } catch (e) {
      print('Erro ao salvar token FCM: $e');
    }
  }

  Future<User?> _userFromFirebase(firebase_auth.User? user) async {
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists ? User.fromMap(userDoc.data()!) : null;
  }

  Future<User?> get currentUser async {
    final user = _auth.currentUser;
    return user != null ? await _userFromFirebase(user) : null;
  }

  Stream<User?> get user =>
      _auth.authStateChanges().asyncMap(_userFromFirebase);

  Future<User?> login(String email, String password) async {
    try {
      final uc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _userFromFirebase(uc.user);
      if (user != null) {
        await _saveFcmTokenToFirestore(user.id);
      }
      return user;
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

      await _saveFcmTokenToFirestore(newUserId);

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
        print(' Erro ao processar usuários do snapshot: $e');
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
      print(' Erro ao buscar voluntários: $e');
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

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? occupation,
    String? description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final uid = user.uid;
    final data = {
      'name': name,
      'phone': phone,
      'occupation': occupation,
      'description': description,
    };

    await _firestore.collection('users').doc(uid).update(data);
  }

  deleteUserAccount({
    required String targetUserId,
    required String currentUserPassword,
    required bool isLeader,
  }) {}
}
*/
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import '../utils/firebase_error_utils.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  AuthService({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> _saveFcmTokenToFirestore(String userId) async {
    try {
      if (!Platform.isAndroid) {
        print('📱 Ignorando FCM: plataforma iOS sem APNs configurado.');
        return;
      }

      final token =
          await messagingInstance.getToken(); // ← aqui usamos o getter
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
        });
        print('Token FCM salvo com sucesso: $token');
      }
    } catch (e) {
      print('Erro ao salvar token FCM: $e');
    }
  }

  FirebaseMessaging get messagingInstance => FirebaseMessaging.instance;

  Future<User?> _userFromFirebase(firebase_auth.User? user) async {
    if (user == null) return null;
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists ? User.fromMap(userDoc.data()!) : null;
  }

  Future<User?> get currentUser async {
    final user = _auth.currentUser;
    return user != null ? await _userFromFirebase(user) : null;
  }

  Stream<User?> get user =>
      _auth.authStateChanges().asyncMap(_userFromFirebase);

  Future<User?> login(String email, String password) async {
    try {
      final uc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await _userFromFirebase(uc.user);
      if (user != null) {
        await _saveFcmTokenToFirestore(user.id);
      }
      return user;
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

      await _saveFcmTokenToFirestore(newUserId);

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
        print(' Erro ao processar usuários do snapshot: $e');
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
      print(' Erro ao buscar voluntários: $e');
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

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? occupation,
    String? description,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final uid = user.uid;
    final data = {
      'name': name,
      'phone': phone,
      'occupation': occupation,
      'description': description,
    };

    await _firestore.collection('users').doc(uid).update(data);
  }

  deleteUserAccount({
    required String targetUserId,
    required String currentUserPassword,
    required bool isLeader,
  }) {}
}
