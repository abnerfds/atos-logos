import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atos_logos_mobile/features/members/presentation/widgets/inactivate_member_dialog.dart';

void main() {
  group('InactivateMemberDialog', () {
    testWidgets('should display confirmation text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => InactivateMemberDialog(
                  memberName: 'Ana Beatriz Silva',
                  onConfirm: () {},
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Inativar Membro?'), findsOneWidget);
      expect(find.textContaining('Ana Beatriz Silva'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Inativar'), findsOneWidget);
    });

    testWidgets('should call onConfirm when Inativar is tapped',
        (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => InactivateMemberDialog(
                  memberName: 'Ana',
                  onConfirm: () => confirmed = true,
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inativar'));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });

    testWidgets('should close dialog when Cancelar is tapped',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => InactivateMemberDialog(
                  memberName: 'João',
                  onConfirm: () {},
                ),
              ),
              child: const Text('Show'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text('Inativar Membro?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Inativar Membro?'), findsNothing);
    });
  });
}
