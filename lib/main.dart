/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tccapp/services/auth_service.dart';
import 'package:tccapp/models/user.dart';
import 'package:tccapp/views/change_password_page.dart';
import 'package:tccapp/views/login_page.dart';
import 'package:tccapp/views/master_home_page.dart';
import 'package:tccapp/views/leader_home_page.dart';
import 'package:tccapp/views/volunteer_home_page.dart';
import 'package:tccapp/views/registration_page.dart';
import 'package:tccapp/views/profile_page.dart';
import 'package:tccapp/views/group_list_page.dart';
import 'package:tccapp/utils/app_theme.dart';
import 'firebase_options.dart';
import 'views/forgot_password_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(" Mensagem em segundo plano: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Voluntários',
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/registration': (_) => const RegistrationPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
      onUnknownRoute:
          (_) => MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _saveFcmToken(String userId) async {
    try {
      if (!Platform.isAndroid) {
        print(' Ignorando FCM em iOS: sem APNs configurado.');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'fcmToken': token},
        );
        print("Token FCM salvo em AuthGate: $token");
      }
    } catch (e) {
      print(' Erro ao obter token FCM no AuthGate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data;
        if (user == null) return const LoginPage();
        _saveFcmToken(user.id);
        return RootNavigation(role: user.role);
      },
    );
  }
}

class RootNavigation extends StatefulWidget {
  final String role;
  const RootNavigation({required this.role, super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      if (widget.role == 'Master')
        MasterHomePage()
      else if (widget.role == 'Líder')
        const LeaderHomePage()
      else
        const VolunteerHomePage(),
      const GroupListPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: cs.primary,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Grupos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
*/
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tccapp/services/auth_service.dart';
import 'package:tccapp/models/user.dart';
import 'package:tccapp/views/change_password_page.dart';
import 'package:tccapp/views/login_page.dart';
import 'package:tccapp/views/master_home_page.dart';
import 'package:tccapp/views/leader_home_page.dart';
import 'package:tccapp/views/volunteer_home_page.dart';
import 'package:tccapp/views/registration_page.dart';
import 'package:tccapp/views/profile_page.dart';
import 'package:tccapp/views/group_list_page.dart';
import 'package:tccapp/utils/app_theme.dart';
import 'firebase_options.dart';
import 'views/forgot_password_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(" Mensagem em segundo plano: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Crashlytics: captura erros não tratados
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Voluntários',
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/registration': (_) => const RegistrationPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
      onUnknownRoute:
          (_) => MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _saveFcmToken(String userId) async {
    try {
      if (!Platform.isAndroid) {
        print(' Ignorando FCM em iOS: sem APNs configurado.');
        return;
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'fcmToken': token},
        );
        print("Token FCM salvo em AuthGate: $token");
      }
    } catch (e) {
      print(' Erro ao obter token FCM no AuthGate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().user,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snap.data;
        if (user == null) return const LoginPage();
        _saveFcmToken(user.id);
        return RootNavigation(role: user.role);
      },
    );
  }
}

class RootNavigation extends StatefulWidget {
  final String role;
  const RootNavigation({required this.role, super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      if (widget.role == 'Master')
        MasterHomePage()
      else if (widget.role == 'Líder')
        const LeaderHomePage()
      else
        const VolunteerHomePage(),
      const GroupListPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: cs.primary,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Grupos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
