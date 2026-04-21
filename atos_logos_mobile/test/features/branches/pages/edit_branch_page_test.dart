import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/branches/domain/models/branch.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_cubit.dart';
import 'package:atos_logos_mobile/features/branches/presentation/cubit/branches_state.dart';
import 'package:atos_logos_mobile/features/branches/presentation/pages/edit_branch_page.dart';

class MockBranchesCubit extends MockCubit<BranchesState>
    implements BranchesCubit {}

void main() {
  late MockBranchesCubit mockCubit;

  const branches = [
    Branch(
      id: 'b1',
      name: 'Sede Central',
      isHeadquarters: true,
      city: 'São Paulo',
    ),
    Branch(
      id: 'b2',
      name: 'Filial Norte',
      isHeadquarters: false,
      city: 'Guarulhos',
      street: 'Rua X',
      number: '42',
    ),
  ];

  setUpAll(() {
    // The edit form is long enough that the save + delete buttons fall
    // below the default 800x600 test viewport. Bumping the height lets
    // tests tap those buttons without fighting the scroll view.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockCubit = MockBranchesCubit();
    when(() => mockCubit.loadBranches(search: any(named: 'search')))
        .thenAnswer((_) async {});
    when(() => mockCubit.updateBranch(
          id: any(named: 'id'),
          name: any(named: 'name'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          neighborhood: any(named: 'neighborhood'),
          street: any(named: 'street'),
          number: any(named: 'number'),
        )).thenAnswer((_) async {});
    when(() => mockCubit.deleteBranch(any())).thenAnswer((_) async {});
    when(() => mockCubit.promoteToHeadquarters(any()))
        .thenAnswer((_) async {});
  });

  Widget buildSubject({
    required String branchId,
    BranchesState? state,
  }) {
    final resolved =
        state ?? const BranchesState.loaded(branches: branches);
    when(() => mockCubit.state).thenReturn(resolved);
    when(() => mockCubit.stream).thenAnswer((_) => Stream.value(resolved));

    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/edit-branch/$branchId'),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/edit-branch/:id',
          builder: (context, state) => BlocProvider<BranchesCubit>.value(
            value: mockCubit,
            // Mirror the production AuthenticatedShell: the page is
            // rendered inside a Scaffold, which provides the Material
            // ancestor that Material widgets (TextFormField) need.
            child: Scaffold(
              body: EditBranchPage(branchId: state.pathParameters['id']!),
            ),
          ),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  Future<void> openEdit(WidgetTester tester, String branchId) async {
    // Taller viewport so the form's save/delete buttons sit within
    // hit-test bounds without needing programmatic scroll.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject(branchId: branchId));
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
  }

  group('EditBranchPage - Layout', () {
    testWidgets(
        'should pre-fill the form fields with the branch data looked up by id',
        (tester) async {
      await openEdit(tester, 'b2');

      expect(find.widgetWithText(TextFormField, 'Filial Norte'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Guarulhos'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Rua X'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '42'), findsOneWidget);
    });

    testWidgets(
        'should OMIT the "Zona de Perigo" section for the headquarters branch (cannot be deleted)',
        (tester) async {
      await openEdit(tester, 'b1');

      expect(find.text('Zona de Perigo'), findsNothing);
      expect(find.text('Remover Congregação'), findsNothing);
      // Title still rendered
      expect(find.text('Editar Congregação'), findsOneWidget);
      expect(find.text('Sede — não pode ser removida'), findsOneWidget);
    });

    testWidgets(
        'should render the "Zona de Perigo" section on a non-headquarters branch',
        (tester) async {
      await openEdit(tester, 'b2');

      expect(find.text('Zona de Perigo'), findsOneWidget);
      expect(find.text('Remover Congregação'), findsOneWidget);
    });

    testWidgets(
        'should render a "não encontrada" message when the requested id does not match any loaded branch',
        (tester) async {
      await openEdit(tester, 'unknown-id');

      expect(find.text('Congregação não encontrada.'), findsOneWidget);
    });

    testWidgets(
        'should trigger BranchesCubit.loadBranches on mount so the state has data to look up',
        (tester) async {
      await openEdit(tester, 'b2');

      verify(() => mockCubit.loadBranches(search: any(named: 'search')))
          .called(greaterThanOrEqualTo(1));
    });
  });

  group('EditBranchPage - Save', () {
    testWidgets(
        'should call BranchesCubit.updateBranch with the form values when Salvar Alterações is tapped',
        (tester) async {
      await openEdit(tester, 'b2');

      // Change the name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Filial Norte'),
        'Filial Renomeada',
      );
      await tester.ensureVisible(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.updateBranch(
            id: 'b2',
            name: 'Filial Renomeada',
            country: any(named: 'country'),
            state: any(named: 'state'),
            city: 'Guarulhos',
            neighborhood: any(named: 'neighborhood'),
            street: 'Rua X',
            number: '42',
          )).called(1);
    });

    testWidgets(
        'should show the backend message in a SnackBar and stay on the page when the update throws',
        (tester) async {
      when(() => mockCubit.updateBranch(
            id: any(named: 'id'),
            name: any(named: 'name'),
            country: any(named: 'country'),
            state: any(named: 'state'),
            city: any(named: 'city'),
            neighborhood: any(named: 'neighborhood'),
            street: any(named: 'street'),
            number: any(named: 'number'),
          )).thenThrow(NetworkException('Branch not found'));

      await openEdit(tester, 'b2');
      await tester.ensureVisible(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Alterações'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Branch not found'), findsOneWidget);
      expect(find.text('Editar Congregação'), findsOneWidget);
    });
  });

  group('EditBranchPage - Delete', () {
    testWidgets(
        'should open the confirmation dialog and call BranchesCubit.deleteBranch when confirmed',
        (tester) async {
      await openEdit(tester, 'b2');

      await tester.ensureVisible(find.text('Remover Congregação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover Congregação'));
      await tester.pumpAndSettle();

      expect(find.text('Remover Congregação?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remover'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.deleteBranch('b2')).called(1);
    });

    testWidgets(
        'should surface the Last-HQ guard message when the backend refuses the delete',
        (tester) async {
      when(() => mockCubit.deleteBranch(any())).thenThrow(
        NetworkException('Cannot delete the headquarters branch'),
      );

      await openEdit(tester, 'b2');

      await tester.ensureVisible(find.text('Remover Congregação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover Congregação'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remover'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Cannot delete the headquarters branch'),
        findsOneWidget,
      );
      expect(find.text('Editar Congregação'), findsOneWidget);
    });

    testWidgets(
        'should NOT call deleteBranch when the user cancels the dialog',
        (tester) async {
      await openEdit(tester, 'b2');

      await tester.ensureVisible(find.text('Remover Congregação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover Congregação'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => mockCubit.deleteBranch(any()));
    });
  });

  group('EditBranchPage - Promote to HQ', () {
    testWidgets(
        'should OMIT the "Tornar esta a Sede" section for the headquarters (already HQ)',
        (tester) async {
      await openEdit(tester, 'b1');

      expect(find.text('Tornar esta a Sede'), findsNothing);
    });

    testWidgets(
        'should render the "Tornar esta a Sede" button on a Filial (non-HQ) branch',
        (tester) async {
      await openEdit(tester, 'b2');

      expect(find.text('Tornar esta a Sede'), findsOneWidget);
    });

    testWidgets(
        'should open the confirmation dialog and call promoteToHeadquarters when confirmed',
        (tester) async {
      await openEdit(tester, 'b2');

      await tester.ensureVisible(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();

      expect(find.text('Tornar Sede?'), findsOneWidget);
      // Dialog content warns about demoting the current HQ
      expect(
        find.textContaining('Sede atual será automaticamente rebaixada'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Tornar Sede'));
      await tester.pumpAndSettle();

      verify(() => mockCubit.promoteToHeadquarters('b2')).called(1);
    });

    testWidgets(
        'should surface the backend 409 guard message when the target is already HQ',
        (tester) async {
      when(() => mockCubit.promoteToHeadquarters(any())).thenThrow(
        NetworkException('Branch is already the headquarters'),
      );

      await openEdit(tester, 'b2');

      await tester.ensureVisible(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tornar Sede'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(
        find.text('Branch is already the headquarters'),
        findsOneWidget,
      );
      expect(find.text('Editar Congregação'), findsOneWidget);
    });

    testWidgets(
        'should NOT call promoteToHeadquarters when the user cancels the dialog',
        (tester) async {
      await openEdit(tester, 'b2');

      await tester.ensureVisible(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => mockCubit.promoteToHeadquarters(any()));
    });

    testWidgets(
        'should show a generic PT-BR SnackBar when the promote throws a non-AppException',
        (tester) async {
      when(() => mockCubit.promoteToHeadquarters(any()))
          .thenThrow(const FormatException('bad JSON'));

      await openEdit(tester, 'b2');
      await tester.ensureVisible(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tornar esta a Sede'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tornar Sede'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Erro inesperado ao promover.'), findsOneWidget);
    });
  });

  group('EditBranchPage - Unexpected error paths', () {
    testWidgets(
        'should show a generic PT-BR SnackBar when the update throws a non-AppException',
        (tester) async {
      when(() => mockCubit.updateBranch(
            id: any(named: 'id'),
            name: any(named: 'name'),
            country: any(named: 'country'),
            state: any(named: 'state'),
            city: any(named: 'city'),
            neighborhood: any(named: 'neighborhood'),
            street: any(named: 'street'),
            number: any(named: 'number'),
          )).thenThrow(const FormatException('bad JSON'));

      await openEdit(tester, 'b2');
      await tester.ensureVisible(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar Alterações'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Erro inesperado ao salvar.'), findsOneWidget);
    });

    testWidgets(
        'should show a generic PT-BR SnackBar when the delete throws a non-AppException',
        (tester) async {
      when(() => mockCubit.deleteBranch(any()))
          .thenThrow(const FormatException('bad JSON'));

      await openEdit(tester, 'b2');
      await tester.ensureVisible(find.text('Remover Congregação'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover Congregação'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Remover'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Erro inesperado ao remover.'), findsOneWidget);
    });
  });

  group('EditBranchPage - Navigation out', () {
    testWidgets(
        'should pop when the header back arrow is tapped',
        (tester) async {
      await openEdit(tester, 'b2');

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget);
    });

    testWidgets(
        'should render an empty SizedBox when the cubit is in initial state (orElse branch)',
        (tester) async {
      await tester.pumpWidget(buildSubject(
        branchId: 'b2',
        state: const BranchesState.initial(),
      ));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      // Form not rendered, no spinner, no error text
      expect(find.text('Editar Congregação'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('EditBranchPage - Loading / Error state', () {
    testWidgets(
        'should render a progress indicator while the cubit is still loading the list',
        (tester) async {
      await tester.pumpWidget(buildSubject(
        branchId: 'b2',
        state: const BranchesState.loading(),
      ));
      // No pumpAndSettle — the spinner animates forever and would time out.
      await tester.tap(find.text('OPEN'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should render the error message when the cubit is in error state',
        (tester) async {
      await tester.pumpWidget(buildSubject(
        branchId: 'b2',
        state: const BranchesState.error(message: 'Erro de rede'),
      ));
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('Erro de rede'), findsOneWidget);
    });
  });
}
