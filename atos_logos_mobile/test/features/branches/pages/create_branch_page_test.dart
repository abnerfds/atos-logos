import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_cubit.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_state.dart';
import 'package:atos_logos_mobile/features/branches/presentation/pages/create_branch_page.dart';

class MockBranchesCubit extends MockCubit<BranchesState>
    implements BranchesCubit {}

void main() {
  late MockBranchesCubit mockCubit;

  setUp(() {
    mockCubit = MockBranchesCubit();
    when(() => mockCubit.state).thenReturn(const BranchesState.initial());
    when(() => mockCubit.createBranch(
          name: any(named: 'name'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          neighborhood: any(named: 'neighborhood'),
          street: any(named: 'street'),
          number: any(named: 'number'),
        )).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<BranchesCubit>.value(
        value: mockCubit,
        // CreateBranchPage returns a Container — the Scaffold comes from
        // the outer AuthenticatedShell in production. Tests mirror that
        // by wrapping in a Scaffold so TextFields find a Material
        // ancestor.
        child: const Scaffold(body: CreateBranchPage()),
      ),
    );
  }

  /// Hosts the page under a real GoRouter so `context.pop()` on the back
  /// button / Cancelar / successful save is observable.
  Widget buildRoutedSubject() {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/create-branch'),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/create-branch',
          builder: (context, state) => BlocProvider<BranchesCubit>.value(
            value: mockCubit,
            // Same reason as buildSubject: Scaffold mirrors the shell.
            child: const Scaffold(body: CreateBranchPage()),
          ),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  Future<void> openCreate(WidgetTester tester) async {
    await tester.pumpWidget(buildRoutedSubject());
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
  }

  group('CreateBranchPage - Layout', () {
    testWidgets(
        'should render the "Nova Unidade" headline and the Dados + Localização sections',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('Nova Unidade'), findsOneWidget);
      expect(find.text('Dados da Unidade'), findsOneWidget);
      expect(find.text('Localização'), findsOneWidget);
    });

    testWidgets(
        'should render every labeled address field (NOME, PAÍS, ESTADO, CIDADE, BAIRRO, RUA, NÚMERO)',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('NOME'), findsOneWidget);
      expect(find.text('PAÍS'), findsOneWidget);
      expect(find.text('ESTADO'), findsOneWidget);
      expect(find.text('CIDADE'), findsOneWidget);
      expect(find.text('BAIRRO'), findsOneWidget);
      expect(find.text('RUA'), findsOneWidget);
      expect(find.text('NÚMERO'), findsOneWidget);
    });

    testWidgets(
        'should NOT render a "TIPO" read-only field (removed because the backend always creates non-HQ branches)',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.text('TIPO'), findsNothing);
      expect(find.text('Filial'), findsNothing);
    });
  });

  group('CreateBranchPage - Validation', () {
    testWidgets(
        'should show "Informe o nome da congregação" validation error when name is empty',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.ensureVisible(find.text('Salvar Unidade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Unidade'));
      await tester.pump();

      expect(find.text('Informe o nome da congregação'), findsOneWidget);
      verifyNever(() => mockCubit.createBranch(
            name: any(named: 'name'),
            country: any(named: 'country'),
            state: any(named: 'state'),
            city: any(named: 'city'),
            neighborhood: any(named: 'neighborhood'),
            street: any(named: 'street'),
            number: any(named: 'number'),
          ));
    });
  });

  group('CreateBranchPage - Submit', () {
    testWidgets(
        'should call BranchesCubit.createBranch with the trimmed form values and null-out empty optionals',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      // Fill just the required name and leave optionals blank to confirm
      // the page converts "" into nulls before hitting the cubit.
      await tester.enterText(find.byType(TextFormField).first, 'Filial Norte');
      await tester.ensureVisible(find.text('Salvar Unidade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Unidade'));
      await tester.pump();

      verify(() => mockCubit.createBranch(
            name: 'Filial Norte',
            country: null,
            state: null,
            city: null,
            neighborhood: null,
            street: null,
            number: null,
          )).called(1);
    });

    testWidgets(
        'should forward every filled-in address field to the cubit',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Filial Leste');
      await tester.enterText(fields.at(1), 'Brasil');
      await tester.enterText(fields.at(2), 'SP');
      await tester.enterText(fields.at(3), 'São Paulo');
      await tester.enterText(fields.at(4), 'Centro');
      await tester.enterText(fields.at(5), 'Rua X');
      await tester.enterText(fields.at(6), '42');

      await tester.ensureVisible(find.text('Salvar Unidade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Unidade'));
      await tester.pump();

      verify(() => mockCubit.createBranch(
            name: 'Filial Leste',
            country: 'Brasil',
            state: 'SP',
            city: 'São Paulo',
            neighborhood: 'Centro',
            street: 'Rua X',
            number: '42',
          )).called(1);
    });
  });

  group('CreateBranchPage - Listener initial + loading', () {
    testWidgets(
        'should render the form (not pop, not snackbar) when the cubit is in initial state',
        (tester) async {
      // Initial state is the default from setUp; the listener's `initial`
      // and `loading` branches are no-ops — the form should just render.
      await tester.pumpWidget(buildSubject());

      expect(find.text('Nova Unidade'), findsOneWidget);
    });

    testWidgets(
        'should keep rendering the form while the cubit is in loading state (no pop mid-flight)',
        (tester) async {
      whenListen(
        mockCubit,
        Stream<BranchesState>.fromIterable(const [
          BranchesState.loading(),
        ]),
        initialState: const BranchesState.initial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Nova Unidade'), findsOneWidget);
    });
  });

  group('CreateBranchPage - Listener', () {
    testWidgets(
        'should pop the route when the cubit transitions to loaded (success — reload handled by the caller)',
        (tester) async {
      await openCreate(tester);
      expect(find.text('Nova Unidade'), findsOneWidget);

      // Simulate the cubit finishing the create + reload cycle
      whenListen(
        mockCubit,
        Stream<BranchesState>.fromIterable(const [
          BranchesState.loading(),
          BranchesState.loaded(branches: []),
        ]),
        initialState: const BranchesState.initial(),
      );

      // Rebuild to wire the new stream
      await tester.pumpWidget(buildRoutedSubject());
      // The router is back on /host; push /create-branch again so the
      // listener attaches to the new stream.
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget);
      expect(find.text('Nova Unidade'), findsNothing);
    });

    testWidgets(
        'should show the error message in a SnackBar when the cubit transitions to error',
        (tester) async {
      whenListen(
        mockCubit,
        Stream<BranchesState>.fromIterable(const [
          BranchesState.loading(),
          BranchesState.error(message: 'Erro ao criar congregação'),
        ]),
        initialState: const BranchesState.initial(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Erro ao criar congregação'), findsOneWidget);
      // Page stays mounted — no silent pop on error
      expect(find.text('Nova Unidade'), findsOneWidget);
    });
  });

  group('CreateBranchPage - Navigation out', () {
    testWidgets(
        'should pop when the header back arrow is tapped',
        (tester) async {
      await openCreate(tester);
      expect(find.text('Nova Unidade'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets(
        'should pop when the "Cancelar" button is tapped',
        (tester) async {
      await openCreate(tester);

      await tester.ensureVisible(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget);
    });
  });
}
