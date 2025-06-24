// test/mocks.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mockito/annotations.dart';
import 'package:tccapp/services/auth_service.dart';
import 'package:tccapp/services/event_service.dart';

@GenerateMocks(
  [
    FirebaseFirestore,
    CollectionReference,
    DocumentReference,
    DocumentSnapshot,
    Query,
    QuerySnapshot,
    QueryDocumentSnapshot,
    firebase_auth.FirebaseAuth,
    firebase_auth.User,
    firebase_auth.UserCredential,
    FirebaseFunctions,
    FirebaseMessaging,
    EventService,
    AuthService,
    HttpsCallable,
    HttpsCallableResult,
  ],
  customMocks: [
    MockSpec<WriteBatch>(as: #MockFirestoreBatch), // nome único
  ],
)
void main() {}
