import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tccapp/models/user.dart';

import 'mocks.mocks.dart';

class FakeMasterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text('Master');
}

class FakeLeaderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text('Líder');
}

class FakeVolunteerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text('Voluntário');
}

class TestRootNavigation extends StatelessWidget {
  final String role;
  const TestRootNavigation({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == 'Master') return FakeMasterPage();
    if (role == 'Líder') return FakeLeaderPage();
    return FakeVolunteerPage();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;

  setUpAll(() {
    mockAuthService = MockAuthService();
  });

  Widget createTestableWidget(User user) {
    when(mockAuthService.user).thenAnswer((_) => Stream.value(user));
    return MaterialApp(home: TestRootNavigation(role: user.role));
  }

  testWidgets('Redireciona para MasterPage se role == Master', (tester) async {
    final user = User(
      id: '1',
      name: 'Admin',
      email: 'admin@mail.com',
      role: 'Master',
      groupIds: [],
    );

    await tester.pumpWidget(createTestableWidget(user));
    await tester.pumpAndSettle();

    expect(find.text('Master'), findsOneWidget);
  });

  testWidgets('Redireciona para LeaderPage se role == Líder', (tester) async {
    final user = User(
      id: '2',
      name: 'Líder',
      email: 'lider@mail.com',
      role: 'Líder',
      groupIds: [],
    );

    await tester.pumpWidget(createTestableWidget(user));
    await tester.pumpAndSettle();

    expect(find.text('Líder'), findsOneWidget);
  });

  testWidgets('Redireciona para VolunteerPage se role == Voluntário', (
    tester,
  ) async {
    final user = User(
      id: '3',
      name: 'Voluntário',
      email: 'voluntario@mail.com',
      role: 'Voluntário',
      groupIds: [],
    );

    await tester.pumpWidget(createTestableWidget(user));
    await tester.pumpAndSettle();

    expect(find.text('Voluntário'), findsOneWidget);
  });
}
