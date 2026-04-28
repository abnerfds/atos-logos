import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/shared/widgets/app_drawer.dart';

void main() {
  Widget buildSubject({String? churchName, void Function(String)? onNavigate}) {
    return MaterialApp(
      home: Scaffold(
        drawer: AppDrawer(
          churchName: churchName ?? 'Atos Logos',
          onNavigate: onNavigate ?? (_) {},
        ),
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            child: const Text('Open'),
          ),
        ),
      ),
    );
  }

  group('AppDrawer', () {
    testWidgets('should display church name and subtitle', (tester) async {
      await tester.pumpWidget(buildSubject(churchName: 'Igreja Teste'));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Igreja Teste'), findsOneWidget);
      expect(find.text('Gestão Eclesiástica'), findsOneWidget);
    });

    testWidgets('should display core modules section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Secretaria'), findsOneWidget);
      expect(find.text('Finanças'), findsOneWidget);
      expect(find.text('Patrimônio'), findsOneWidget);
      expect(find.text('Congregações'), findsOneWidget);
      expect(find.text('EBD'), findsOneWidget);
    });

    testWidgets('should display tools section', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Relatórios'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Relatórios'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Célula'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Certificados'), findsOneWidget);
      expect(find.text('Contribuições'), findsOneWidget);
      expect(find.text('Célula'), findsOneWidget);
    });

    testWidgets(
      'should call onNavigate with "congregacoes" when the Congregações item is tapped',
      (tester) async {
        String? navigatedTo;
        await tester.pumpWidget(
          buildSubject(onNavigate: (route) => navigatedTo = route),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Congregações'));
        await tester.pumpAndSettle();
        expect(navigatedTo, 'congregacoes');
      },
    );

    testWidgets(
      'should call onNavigate with "ebd" when the EBD item is tapped',
      (tester) async {
        String? navigatedTo;
        await tester.pumpWidget(
          buildSubject(onNavigate: (route) => navigatedTo = route),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('EBD'));
        await tester.pumpAndSettle();
        expect(navigatedTo, 'ebd');
      },
    );

    testWidgets(
      'should call onNavigate with "secretaria" when the Secretaria item is tapped',
      (tester) async {
        String? navigatedTo;
        await tester.pumpWidget(
          buildSubject(onNavigate: (route) => navigatedTo = route),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Secretaria'));
        await tester.pumpAndSettle();
        expect(navigatedTo, 'secretaria');
      },
    );

    testWidgets(
      'should show EM BREVE badge and not navigate for coming-soon modules',
      (tester) async {
        String? navigatedTo;
        await tester.pumpWidget(
          buildSubject(onNavigate: (route) => navigatedTo = route),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Badge visible for Finanças and Patrimônio
        expect(find.text('EM BREVE'), findsWidgets);

        // Tapping a coming-soon item does NOT navigate
        await tester.tap(find.text('Finanças'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(navigatedTo, isNull);

        await tester.tap(find.text('Patrimônio'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(navigatedTo, isNull);
      },
    );

    testWidgets(
      'should show EM BREVE badge for all tools section items',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Célula'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        // At least the visible coming-soon items show the badge
        expect(find.text('EM BREVE'), findsWidgets);
      },
    );

    testWidgets('should display system status footer', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Status do Sistema'), findsOneWidget);
    });
  });
}
