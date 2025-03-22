import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
 import 'package:cloud_firestore/cloud_firestore.dart';
 import '../models/user.dart';
 
 class AuthService {
   final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
   // Converte um FirebaseUser para o modelo User do app
   Future<User?> _userFromFirebase(firebase_auth.User? user) async {
     if (user == null) return null;
 
     // Recupera as informações do usuário do Firestore
     final userDoc = await _firestore.collection('users').doc(user.uid).get();
     if (userDoc.exists) {
       return User.fromMap(userDoc.data()!); // Retorna o usuário com o papel
     } else {
       return null;
     }
   }
 
   // Getter para o usuário atual
   Future<User?> get currentUser async {
     final user = _auth.currentUser;
     if (user == null) return null;
     return await _userFromFirebase(user);
   }
 
   // Stream para monitorar o estado de autenticação
   Stream<User?> get user {
     return _auth.authStateChanges().asyncMap((user) async {
       if (user == null) return null;
       return await _userFromFirebase(user);
     });
   }
 
   // Login com email e senha
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
 
   // Registro de novo usuário
   Future<User?> register(String email, String password, String name, String role) async {
     try {
       // Cria o usuário no Firebase Authentication
       final userCredential = await _auth.createUserWithEmailAndPassword(
         email: email,
         password: password,
       );
 
       // Salva informações adicionais no Firestore
       await _firestore.collection('users').doc(userCredential.user!.uid).set({
         'id': userCredential.user!.uid, // Adiciona o ID do usuário
         'name': name,
         'email': email,
         'role': role,
         'groupIds': [],
       });
 
       // Retorna o usuário criado
       return await _userFromFirebase(userCredential.user);
     } on firebase_auth.FirebaseAuthException catch (e) {
       // Captura exceções específicas do Firebase Auth
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
 
   // Logout
   Future<void> logout() async {
     await _auth.signOut();
   }
 
   // Remove um usuário
   Future<void> removeUser(User user) async {
  try {
    // Exclui o usuário do Firestore
    await _firestore.collection('users').doc(user.id).delete();

    // Exclui o usuário do Firebase Authentication
    await _auth.currentUser?.delete();
  } catch (e) {
    print('Erro ao excluir usuário: $e');
    throw e;
  }
}
 
   // Obtém todos os usuários
   Stream<List<User>> getUsers() {
     return _firestore.collection('users').snapshots().map((snapshot) {
       return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
     });
   }
 }