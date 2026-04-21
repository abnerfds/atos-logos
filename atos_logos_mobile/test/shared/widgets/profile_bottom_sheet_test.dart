import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/shared/widgets/profile_bottom_sheet.dart';

void main() {
  Widget buildSubject({
    String userName = 'Atos Logos Admin',
    String userRole = 'ADMIN',
    VoidCallback? onMyProfile,
    VoidCallback? onSettings,
    VoidCallback? onLogout,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileBottomSheet(
          userName: userName,
          userRole: userRole,
          onMyProfile: onMyProfile ?? () {},
          onSettings: onSettings ?? () {},
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  group('ProfileBottomSheet', () {
    testWidgets('should display user name and role', (tester) async {
      await tester.pumpWidget(
        buildSubject(userName: 'João Silva', userRole: 'ADMIN'),
      );
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Gestor da Comunidade'), findsOneWidget);
    });

    testWidgets('should display menu options', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Meu Perfil'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('should call onLogout when Sair is tapped', (tester) async {
      bool logoutCalled = false;
      await tester.pumpWidget(
        buildSubject(onLogout: () => logoutCalled = true),
      );
      await tester.tap(find.text('Sair'));
      await tester.pump();
      expect(logoutCalled, isTrue);
    });

    testWidgets('should call onMyProfile when tapped', (tester) async {
      bool profileCalled = false;
      await tester.pumpWidget(
        buildSubject(onMyProfile: () => profileCalled = true),
      );
      await tester.tap(find.text('Meu Perfil'));
      await tester.pump();
      expect(profileCalled, isTrue);
    });

    testWidgets('should show version text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.textContaining('Versão'), findsOneWidget);
    });

    testWidgets('should show Secretary role label', (tester) async {
      await tester.pumpWidget(buildSubject(userRole: 'SECRETARY'));
      expect(find.text('Secretário(a)'), findsOneWidget);
    });

    testWidgets(
        'should show "Membro" label when role is the explicit MEMBER enum value',
        (tester) async {
      await tester.pumpWidget(buildSubject(userRole: 'MEMBER'));
      expect(find.text('Membro'), findsOneWidget);
    });

    testWidgets(
        'should show "Membro" fallback when role is an unknown value',
        (tester) async {
      await tester.pumpWidget(buildSubject(userRole: 'VISITOR'));
      expect(find.text('Membro'), findsOneWidget);
    });

    testWidgets(
        'should render a "?" avatar placeholder when userName is an empty string',
        (tester) async {
      await tester.pumpWidget(buildSubject(userName: ''));
      expect(find.text('?'), findsOneWidget);
    });
  });
}
