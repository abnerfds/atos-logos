import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/branches/domain/models/branch.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_cubit.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_state.dart';
import 'package:atos_logos_mobile/features/branches/presentation/pages/branches_page.dart';

class MockBranchesCubit extends MockCubit<BranchesState>
    implements BranchesCubit {}

void main() {
  late MockBranchesCubit mockCubit;

  final branches = [
    const Branch(
      id: '1',
      name: 'Sede Central',
      isHeadquarters: true,
      neighborhood: 'Centro',
      street: 'Av. Principal',
      number: '1000',
    ),
    const Branch(
      id: '2',
      name: 'Capine',
      isHeadquarters: false,
      neighborhood: 'Bairro Capine',
      street: 'Rua das Flores',
      number: '45',
    ),
  ];

  setUp(() {
    mockCubit = MockBranchesCubit();
    when(() => mockCubit.loadBranches()).thenAnswer((_) async {});
  });

  Widget buildSubject(BranchesState state) {
    when(() => mockCubit.state).thenReturn(state);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(state));
    return MaterialApp(
      home: BlocProvider<BranchesCubit>.value(
        value: mockCubit,
        child: const Scaffold(body: BranchesPage()),
      ),
    );
  }

  group('BranchesPage - Layout', () {
    testWidgets('should display page title Congregações', (tester) async {
      await tester.pumpWidget(
        buildSubject(BranchesState.loaded(branches: branches)),
      );
      expect(find.text('Congregações'), findsOneWidget);
    });

    testWidgets('should display branch names from loaded state',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(BranchesState.loaded(branches: branches)),
      );
      expect(find.text('Sede Central'), findsOneWidget);
      expect(find.text('Capine'), findsOneWidget);
    });

    testWidgets('should display Sede badge for headquarters branch',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(BranchesState.loaded(branches: branches)),
      );
      expect(find.text('Sede'), findsOneWidget);
    });

    testWidgets('should display search TextField', (tester) async {
      await tester.pumpWidget(
        buildSubject(BranchesState.loaded(branches: branches)),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display FAB', (tester) async {
      await tester.pumpWidget(
        buildSubject(BranchesState.loaded(branches: branches)),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should display CircularProgressIndicator in loading state',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(const BranchesState.loading()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should render an empty body (no spinner, no error) while state is initial (before loadBranches resolves)',
        (tester) async {
      await tester.pumpWidget(buildSubject(const BranchesState.initial()));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Tentar novamente'), findsNothing);
      // Page header still there — we only hide the body content.
      expect(find.text('Congregações'), findsOneWidget);
    });
  });

  group('BranchesPage - Error state', () {
    testWidgets(
        'should render the error message and a retry button when state is error',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(const BranchesState.error(message: 'Erro ao carregar')),
      );

      expect(find.text('Erro ao carregar'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets(
        'should call BranchesCubit.loadBranches when the retry button is tapped',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(const BranchesState.error(message: 'Erro de rede')),
      );

      // loadBranches is also called on initState; reset so the retry
      // verification is unambiguous.
      clearInteractions(mockCubit);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      verify(() => mockCubit.loadBranches()).called(1);
    });
  });

  group('BranchesPage - Empty state', () {
    testWidgets(
        'should render "Nenhuma congregação cadastrada" when loaded list is empty and no search is active',
        (tester) async {
      await tester.pumpWidget(
        buildSubject(const BranchesState.loaded(branches: [])),
      );

      expect(find.text('Nenhuma congregação cadastrada'), findsOneWidget);
    });

    testWidgets(
        'should render "Nenhum resultado encontrado" when loaded state carries a non-empty searchQuery and an empty branches list',
        (tester) async {
      // Server-side search: the backend returned no rows for the query,
      // so the state arrives as loaded(branches: [], searchQuery: 'X').
      await tester.pumpWidget(
        buildSubject(const BranchesState.loaded(
          branches: [],
          searchQuery: 'zzz-nope',
        )),
      );

      expect(find.text('Nenhum resultado encontrado'), findsOneWidget);
    });
  });

  group('BranchesPage - Search (server-side)', () {
    testWidgets(
        'should forward every keystroke to BranchesCubit.search (backend filters; UI no longer filters client-side)',
        (tester) async {
      when(() => mockCubit.search(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildSubject(BranchesState.loaded(branches: branches)),
      );

      await tester.enterText(find.byType(TextField), 'Sede');
      await tester.pump();

      verify(() => mockCubit.search('Sede')).called(1);
    });
  });

  group('BranchesPage - Tile navigation', () {
    testWidgets(
        'should push /edit-branch/:id and reload the list on pop when a branch tile is tapped',
        (tester) async {
      when(() => mockCubit.state)
          .thenReturn(BranchesState.loaded(branches: branches));
      when(() => mockCubit.stream).thenAnswer(
        (_) => Stream.value(BranchesState.loaded(branches: branches)),
      );

      final router = GoRouter(
        initialLocation: '/branches',
        routes: [
          GoRoute(
            path: '/branches',
            builder: (context, state) => BlocProvider<BranchesCubit>.value(
              value: mockCubit,
              child: const Scaffold(body: BranchesPage()),
            ),
          ),
          GoRoute(
            path: '/edit-branch/:id',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text('EDIT_${state.pathParameters['id']}'),
                ),
              ),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      clearInteractions(mockCubit);

      // Tap the first branch tile
      await tester.tap(find.text('Sede Central'));
      await tester.pumpAndSettle();

      // We're on /edit-branch/1
      expect(find.text('EDIT_1'), findsOneWidget);

      await tester.tap(find.text('EDIT_1'));
      await tester.pumpAndSettle();

      // Back on /branches and the list was reloaded
      verify(() => mockCubit.loadBranches()).called(1);
    });
  });

  group('BranchesPage - FAB navigation', () {
    testWidgets(
        'should push /create-branch AND reload the list once the route pops (so newly-created branches appear without a manual refresh)',
        (tester) async {
      when(() => mockCubit.state)
          .thenReturn(BranchesState.loaded(branches: branches));
      when(() => mockCubit.stream).thenAnswer(
        (_) => Stream.value(BranchesState.loaded(branches: branches)),
      );

      final router = GoRouter(
        initialLocation: '/branches',
        routes: [
          GoRoute(
            path: '/branches',
            builder: (context, state) => BlocProvider<BranchesCubit>.value(
              value: mockCubit,
              child: const Scaffold(body: BranchesPage()),
            ),
          ),
          GoRoute(
            path: '/create-branch',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('POP'),
                ),
              ),
            ),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // initState has already fired loadBranches once — clear so we can
      // verify the POST-POP reload cleanly.
      clearInteractions(mockCubit);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // We're now on /create-branch
      expect(find.text('POP'), findsOneWidget);

      await tester.tap(find.text('POP'));
      await tester.pumpAndSettle();

      // Back on /branches, and the FAB handler fired the reload
      verify(() => mockCubit.loadBranches()).called(1);
    });
  });
}
