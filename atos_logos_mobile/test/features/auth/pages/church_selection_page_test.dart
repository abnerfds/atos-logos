// test/features/auth/pages/church_selection_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/auth/domain/models/church_option.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/auth/presentation/pages/church_selection_page.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  const sampleChurches = [
    ChurchOption(
      id: 'c1',
      name: 'Igreja Sede Central',
      branchName: 'Sede',
      role: 'ADMIN',
    ),
    ChurchOption(
      id: 'c2',
      name: 'Atos Logos Jardins',
      branchName: 'Jardins',
      role: 'SECRETARY',
    ),
    ChurchOption(
      id: 'c3',
      name: 'Atos Logos Alphaville',
      branchName: 'Alphaville',
      role: 'MEMBER',
    ),
  ];

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state).thenReturn(
      const AuthState.churchSelection(
        selectionToken: 'sel-tkn',
        churches: sampleChurches,
      ),
    );
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const ChurchSelectionPage(),
      ),
    );
  }

  /// Wraps the page in a GoRouter with placeholder destinations so
  /// `context.go('/home')` triggered by the `authenticated` state
  /// transition can be asserted.
  Widget buildRoutedSubject() {
    final router = GoRouter(
      initialLocation: '/select-church',
      routes: [
        GoRoute(
          path: '/select-church',
          builder: (context, state) => BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const ChurchSelectionPage(),
          ),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Text('HOME_ROUTE')),
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  group('ChurchSelectionPage - Layout', () {
    testWidgets(
        'should display the "BEM-VINDO DE VOLTA" eyebrow label when the page renders',
        (tester) async {
      // Given / When — the page is pumped with 3 churches in state
      await tester.pumpWidget(buildSubject());

      // Then — the eyebrow label matches the new design verbatim
      expect(find.text('BEM-VINDO DE VOLTA'), findsOneWidget);
    });

    testWidgets(
        'should display the "Escolha sua comunidade" headline when the page renders',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then
      expect(find.text('Escolha sua comunidade'), findsOneWidget);
    });

    testWidgets(
        'should render exactly one card per church in the cubit state',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — all three church names are visible
      expect(find.text('Igreja Sede Central'), findsOneWidget);
      expect(find.text('Atos Logos Jardins'), findsOneWidget);
      expect(find.text('Atos Logos Alphaville'), findsOneWidget);
    });

    testWidgets(
        'should render the localized role label under each church (Admin / Secretário / Membro)',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — each backend enum value resolves to its friendly PT-BR label
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Secretário'), findsOneWidget);
      expect(find.text('Membro'), findsOneWidget);
    });

    testWidgets(
        'should render the same church icon on every card (decision: single icon per user choice)',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — Icons.church_rounded appears exactly once per church card
      // (sampleChurches has 3 entries)
      expect(
        find.byIcon(Icons.church_rounded),
        findsNWidgets(sampleChurches.length),
      );
    });

    testWidgets(
        'should render a chevron-right affordance on every church card',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — each card has its own chevron
      expect(
        find.byIcon(Icons.chevron_right),
        findsNWidgets(sampleChurches.length),
      );
    });
  });

  group('ChurchSelectionPage - Daily Reflection', () {
    testWidgets(
        'should display the "REFLEXÃO DO DIA" section label when the page renders',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then
      expect(find.text('REFLEXÃO DO DIA'), findsOneWidget);
    });

    testWidgets(
        'should display the hardcoded verse and its biblical attribution',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then — the placeholder content matches what the new design mocked
      expect(
        find.textContaining('Pois onde estiverem dois ou três reunidos'),
        findsOneWidget,
      );
      expect(find.textContaining('Mateus 18:20'), findsOneWidget);
    });

    testWidgets(
        'should display the hardcoded author name and ministry role as placeholder',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject());

      // Then
      expect(find.text('Pr. Ricardo Santos'), findsOneWidget);
      expect(find.text('Ministério de Ensino'), findsOneWidget);
    });
  });

  group('ChurchSelectionPage - Interactions', () {
    testWidgets(
        'should call AuthCubit.selectChurch with the tapped church id',
        (tester) async {
      // Given
      when(() => mockAuthCubit.selectChurch(any())).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());

      // When — the user taps the second church card
      await tester.ensureVisible(find.text('Atos Logos Jardins'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Atos Logos Jardins'));
      await tester.pump();

      // Then — the cubit is called with that church's id exactly once
      verify(() => mockAuthCubit.selectChurch('c2')).called(1);
    });

    testWidgets(
        'should call AuthCubit.selectChurch with the first church id when the first card is tapped',
        (tester) async {
      when(() => mockAuthCubit.selectChurch(any())).thenAnswer((_) async {});
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Igreja Sede Central'));
      await tester.pump();

      verify(() => mockAuthCubit.selectChurch('c1')).called(1);
    });
  });

  group('ChurchSelectionPage - States', () {
    testWidgets(
        'should display a progress indicator when the cubit transitions to loading',
        (tester) async {
      // Given — cubit is loading (user tapped a card and a request is in flight)
      when(() => mockAuthCubit.state).thenReturn(const AuthState.loading());

      // When
      await tester.pumpWidget(buildSubject());

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should show an error snackbar when the cubit emits an error after a failed selection',
        (tester) async {
      // Given — the stream will emit an error after the page is pumped
      whenListen(
        mockAuthCubit,
        Stream.fromIterable(const [
          AuthState.error(message: 'Sem vínculo ativo nesta igreja.'),
        ]),
        initialState: const AuthState.churchSelection(
          selectionToken: 'sel-tkn',
          churches: sampleChurches,
        ),
      );

      // When
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      // Then
      expect(
        find.text('Sem vínculo ativo nesta igreja.'),
        findsOneWidget,
      );
    });
  });

  group('ChurchSelectionPage - Navigation', () {
    testWidgets(
        'should navigate to /home when the cubit transitions to authenticated after a successful selection',
        (tester) async {
      // Given — the cubit will flip to `authenticated` after pump
      whenListen(
        mockAuthCubit,
        Stream.fromIterable(const [AuthState.authenticated()]),
        initialState: const AuthState.churchSelection(
          selectionToken: 'sel-tkn',
          churches: sampleChurches,
        ),
      );

      // When — the page is pumped under a real GoRouter
      await tester.pumpWidget(buildRoutedSubject());
      await tester.pumpAndSettle();

      // Then — the destination placeholder is shown
      expect(find.text('HOME_ROUTE'), findsOneWidget);
    });
  });
}
