import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:atos_logos_mobile/features/home/domain/models/birthday_member.dart';
import 'package:atos_logos_mobile/features/home/domain/models/church.dart';
import 'package:atos_logos_mobile/features/home/domain/models/upcoming_event.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:atos_logos_mobile/features/home/presentation/cubit/home_state.dart';
import 'package:atos_logos_mobile/features/home/presentation/pages/dashboard_page.dart';
import 'package:atos_logos_mobile/features/home/presentation/widgets/flip_card.dart';

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;
  late MockAuthCubit mockAuthCubit;

  final fullProfile = UserProfile(
    user: const UserProfileUser(
      id: 'u1',
      name: 'Ricardo Oliveira',
      email: 'r@e.com',
    ),
    profile: const UserProfileDetail(
      photoUrl: null,
      admissionDate: '2020-03-15',
      birthDate: '1990-05-20',
      registrationNumber: '2020-ABCD-001',
    ),
    membership: const UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
    positions: [const UserProfilePosition(id: 'p1', name: 'Pastor')],
    church: const UserProfileChurch(id: 'c1', name: 'Igreja Teste'),
    branch: const UserProfileBranch(id: 'b1', name: 'Sede'),
  );

  setUp(() {
    mockHomeCubit = MockHomeCubit();
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.state)
        .thenReturn(AuthState.authenticated(profile: fullProfile));
  });

  Widget buildSubject(HomeState state) {
    when(() => mockHomeCubit.state).thenReturn(state);
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          BlocProvider<AuthCubit>.value(value: mockAuthCubit),
        ],
        child: const Scaffold(body: DashboardPage()),
      ),
    );
  }

  /// Taps the FlipCard and waits for its 600ms rotation animation to
  /// settle so the back face is in the widget tree for assertions.
  /// The card only renders front OR back based on the animation value,
  /// so tests that inspect the back must call this first.
  Future<void> flipToCardBack(WidgetTester tester) async {
    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();
  }

  final loadedState = HomeState.loaded(
    church: const Church(id: '1', name: 'Igreja', activePlan: 'free'),
    birthdays: [
      BirthdayMember(id: '1', name: 'Ana', birthDate: '1995-04-12'),
      BirthdayMember(id: '2', name: 'Carlos', birthDate: '1988-04-25'),
    ],
    upcomingEvents: [
      UpcomingEvent(
        id: 'e1',
        title: 'Reunião de Oração',
        startsAt: DateTime(2026, 4, 12, 19, 30),
        branchName: 'Sede Central',
        type: 'SERVICE',
      ),
    ],
  );

  final emptyLoadedState = HomeState.loaded(
    church: const Church(id: '1', name: 'Igreja', activePlan: 'free'),
    birthdays: const [],
    upcomingEvents: const [],
  );

  group('DashboardPage - Loaded state greeting', () {
    testWidgets(
        'should greet the authenticated user with an accented "Olá, [firstName]" when state is loaded',
        (tester) async {
      // Given — loaded state and a user whose first name is "Ricardo"
      // When — the page is pumped
      await tester.pumpWidget(buildSubject(loadedState));

      // Then — the greeting uses the correct Portuguese diacritics
      expect(find.text('Olá, Ricardo'), findsOneWidget);
    });

    testWidgets(
        'should render the accented welcome subtitle "Que bom ter você aqui hoje."',
        (tester) async {
      await tester.pumpWidget(buildSubject(loadedState));
      expect(find.text('Que bom ter você aqui hoje.'), findsOneWidget);
    });

    testWidgets(
        'should render the greeting without a fake "Membro" name when authenticated state has not yet resolved a profile',
        (tester) async {
      // Given — authenticated-no-profile window (fetchProfile still in flight).
      // Historically this rendered "Olá, Membro" as if "Membro" were the user's
      // name — a regression after logout races. The dashboard must NOT treat
      // the literal "Membro" fallback as real user data.
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthState.authenticated());

      // When
      await tester.pumpWidget(buildSubject(loadedState));

      // Then — no fake name is rendered; a neutral "Olá" greeting is shown
      expect(find.text('Olá, Membro'), findsNothing);
      expect(find.textContaining('Membro'), findsNothing);
      expect(find.text('Olá'), findsOneWidget);
    });

    testWidgets(
        'should render the greeting without a fake "Membro" name when profile.user.name is empty',
        (tester) async {
      // Given — authenticated with a profile whose name came back empty from
      // the backend. Still must never surface "Membro".
      const profile = UserProfile(
        user: UserProfileUser(id: 'u1', name: '', email: 'r@e.com'),
        membership: UserProfileMembership(role: 'MEMBER', status: 'ACTIVE'),
        positions: [],
        church: UserProfileChurch(id: 'c1', name: 'Igreja'),
        branch: UserProfileBranch(id: 'b1', name: 'Sede'),
      );
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthState.authenticated(profile: profile));

      await tester.pumpWidget(buildSubject(loadedState));

      expect(find.text('Olá, Membro'), findsNothing);
      expect(find.textContaining('Membro'), findsNothing);
      expect(find.text('Olá'), findsOneWidget);
    });
  });

  group('DashboardPage - Member flip card (front)', () {
    testWidgets(
        'should render the real registrationNumber from the user profile on the card front',
        (tester) async {
      // Given — profile has registrationNumber "2020-ABCD-001"
      // When — the page is pumped in loaded state
      await tester.pumpWidget(buildSubject(loadedState));

      // Then — the card front shows the real number (not the old hardcoded #10234)
      expect(find.text('2020-ABCD-001'), findsOneWidget);
      expect(find.text('#10234'), findsNothing);
    });

    testWidgets(
        'should render "?" on the member card front avatar when profile.user.name is empty (guards against RangeError)',
        (tester) async {
      // Given — a defensive edge case: backend returns an empty name string.
      // The card front indexes `userName[0]`, so without a guard this throws.
      const profile = UserProfile(
        user: UserProfileUser(id: 'u1', name: '', email: 'a@b.com'),
        membership: UserProfileMembership(role: 'MEMBER', status: 'ACTIVE'),
        positions: [],
        church: UserProfileChurch(id: 'c1', name: 'Igreja'),
        branch: UserProfileBranch(id: 'b1', name: 'Sede'),
      );
      when(() => mockAuthCubit.state)
          .thenReturn(const AuthState.authenticated(profile: profile));

      // When
      await tester.pumpWidget(buildSubject(loadedState));

      // Then — no exception AND a "?" avatar is rendered as a neutral fallback
      expect(tester.takeException(), isNull);
      expect(find.text('?'), findsWidgets);
    });

    testWidgets(
        'should fall back to a placeholder registration number when profile.profile is null',
        (tester) async {
      // Given — an authenticated user whose MemberProfile row is absent
      final profileWithoutDetail = UserProfile(
        user: const UserProfileUser(id: 'u1', name: 'Ana', email: 'a@b.com'),
        profile: null,
        membership: const UserProfileMembership(role: 'MEMBER', status: 'ACTIVE'),
        positions: const [],
        church: const UserProfileChurch(id: 'c1', name: 'Igreja'),
        branch: const UserProfileBranch(id: 'b1', name: 'Sede'),
      );
      when(() => mockAuthCubit.state).thenReturn(
        AuthState.authenticated(profile: profileWithoutDetail),
      );

      // When
      await tester.pumpWidget(buildSubject(loadedState));

      // Then — we explicitly do NOT show a fake "#10234"; a neutral
      // placeholder is rendered instead.
      expect(find.text('#10234'), findsNothing);
    });
  });

  group('DashboardPage - Member flip card (back)', () {
    testWidgets(
        'should render the real baptismDate from the user profile on the card back after flipping',
        (tester) async {
      // Given — the profile has a known baptism date that the backend
      // returns as an ISO string ("2018-06-10").
      final profileWithBaptism = UserProfile(
        user: const UserProfileUser(
          id: 'u1',
          name: 'Ricardo',
          email: 'r@e.com',
        ),
        profile: const UserProfileDetail(
          admissionDate: '2020-03-15',
          birthDate: '1990-05-20',
          baptismDate: '2018-06-10',
          registrationNumber: '2020-ABCD-001',
        ),
        membership:
            const UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
        positions: const [],
        church: const UserProfileChurch(id: 'c1', name: 'Igreja'),
        branch: const UserProfileBranch(id: 'b1', name: 'Sede'),
      );
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(profile: profileWithBaptism));
      await tester.pumpWidget(buildSubject(loadedState));

      // When — the user flips the card to reveal the back
      await flipToCardBack(tester);

      // Then — the card back shows the formatted Brazilian date
      // (dd/MM/yyyy) for baptism, AND the BATISMO label is present.
      expect(find.text('BATISMO'), findsOneWidget);
      expect(find.text('10/06/2018'), findsOneWidget);
    });

    testWidgets(
        'should render a "—" placeholder for baptism when the profile has no baptismDate',
        (tester) async {
      // Given — a profile without baptismDate
      final profileNoBaptism = UserProfile(
        user: const UserProfileUser(id: 'u1', name: 'Ana', email: 'a@b.com'),
        profile: const UserProfileDetail(
          admissionDate: '2020-03-15',
          birthDate: '1990-05-20',
          registrationNumber: '2020-ABCD-001',
        ),
        membership:
            const UserProfileMembership(role: 'MEMBER', status: 'ACTIVE'),
        positions: const [],
        church: const UserProfileChurch(id: 'c1', name: 'Igreja'),
        branch: const UserProfileBranch(id: 'b1', name: 'Sede'),
      );
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(profile: profileNoBaptism));
      await tester.pumpWidget(buildSubject(loadedState));

      // When
      await flipToCardBack(tester);

      // Then — the BATISMO field renders with the em-dash placeholder
      expect(find.text('BATISMO'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets(
        'should render the accented "Informações de Registro" header on the card back after flipping',
        (tester) async {
      // Given — the page is loaded
      await tester.pumpWidget(buildSubject(loadedState));

      // When — the user flips the card
      await flipToCardBack(tester);

      // Then — the header with proper Portuguese accents is visible
      expect(find.text('Informações de Registro'), findsOneWidget);
    });

    testWidgets(
        'should render the accented "ADMISSÃO" label on the card back after flipping',
        (tester) async {
      // Given / When
      await tester.pumpWidget(buildSubject(loadedState));
      await flipToCardBack(tester);

      // Then
      expect(find.text('ADMISSÃO'), findsOneWidget);
    });
  });

  group('DashboardPage - Birthdays section', () {
    testWidgets(
        'should render the accented header "Aniversariantes do Mês" when loaded state has birthdays',
        (tester) async {
      await tester.pumpWidget(buildSubject(loadedState));
      expect(find.text('Aniversariantes do Mês'), findsOneWidget);
    });

    testWidgets(
        'should render every birthday member when state is loaded with birthdays',
        (tester) async {
      await tester.pumpWidget(buildSubject(loadedState));
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('Carlos'), findsOneWidget);
    });

    testWidgets(
        'should omit the birthdays section entirely when loaded state has no birthdays',
        (tester) async {
      await tester.pumpWidget(buildSubject(emptyLoadedState));
      expect(find.text('Aniversariantes do Mês'), findsNothing);
    });
  });

  group('DashboardPage - Upcoming events section', () {
    testWidgets(
        'should render the accented header "Próximos Eventos" when loaded',
        (tester) async {
      await tester.pumpWidget(buildSubject(loadedState));
      expect(find.text('Próximos Eventos'), findsOneWidget);
    });

    testWidgets(
        'should render the title of each UpcomingEvent when loaded state has events',
        (tester) async {
      await tester.pumpWidget(buildSubject(loadedState));
      expect(find.text('Reunião de Oração'), findsOneWidget);
    });

    testWidgets(
        'should use branch.name as the location line on the event card (not the literal "Local" placeholder)',
        (tester) async {
      // Given — an event whose branchName is "Sede Central"
      // When — the page is pumped
      await tester.pumpWidget(buildSubject(loadedState));

      // Then — the card shows the branch name as location, NOT the old
      // "Local" literal fallback that existed before the rewrite.
      expect(find.textContaining('Sede Central'), findsOneWidget);
      expect(find.textContaining('• Local'), findsNothing);
    });

    testWidgets(
        'should render the "Nenhum evento cadastrado" empty card when loaded state has no events',
        (tester) async {
      await tester.pumpWidget(buildSubject(emptyLoadedState));
      expect(find.text('Nenhum evento cadastrado'), findsOneWidget);
    });
  });

  group('DashboardPage - Accessibility', () {
    testWidgets(
        'should expose a Semantics label on the member flip card so assistive tech announces it as a tappable card',
        (tester) async {
      await tester.pumpWidget(buildSubject(loadedState));
      expect(
        find.bySemanticsLabel(RegExp(r'carteira.*digital', caseSensitive: false)),
        findsOneWidget,
      );
    });
  });

  group('DashboardPage - Loading state', () {
    testWidgets(
        'should display a progress indicator when state is loading',
        (tester) async {
      await tester.pumpWidget(buildSubject(const HomeState.loading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('DashboardPage - Error state', () {
    testWidgets(
        'should display the error message and a retry button when state is error',
        (tester) async {
      const errorMessage = 'Falha ao carregar dashboard';
      await tester.pumpWidget(
        buildSubject(const HomeState.error(errorMessage)),
      );
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets(
        'should call HomeCubit.loadDashboard when the retry button is tapped',
        (tester) async {
      when(() => mockHomeCubit.loadDashboard()).thenAnswer((_) async {});
      await tester.pumpWidget(
        buildSubject(const HomeState.error('Falha ao carregar dashboard')),
      );

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      verify(() => mockHomeCubit.loadDashboard()).called(1);
    });
  });

  group('DashboardPage - Date formatting on card back', () {
    testWidgets(
        'should render the raw birthDate string on the card back when it is too short to be a valid ISO date',
        (tester) async {
      // Given — birthDate = 'bad' (len 3, no hyphens) exercises the
      // `parts.length != 3` fallback branch inside _formatDate.
      final profile = UserProfile(
        user: const UserProfileUser(id: 'u1', name: 'Ana', email: 'a@b.com'),
        profile: const UserProfileDetail(
          birthDate: 'bad',
          admissionDate: '2020-03-15',
          registrationNumber: 'x',
        ),
        membership:
            const UserProfileMembership(role: 'MEMBER', status: 'ACTIVE'),
        positions: const [],
        church: const UserProfileChurch(id: 'c1', name: 'Igreja'),
        branch: const UserProfileBranch(id: 'b1', name: 'Sede'),
      );
      when(() => mockAuthCubit.state)
          .thenReturn(AuthState.authenticated(profile: profile));
      await tester.pumpWidget(buildSubject(loadedState));

      // When
      await flipToCardBack(tester);

      // Then — the unparseable value passes through verbatim
      expect(find.text('bad'), findsOneWidget);
    });
  });

  group('DashboardPage - Birthday avatar date handling', () {
    testWidgets(
        'should render "--" under a birthday avatar when member.birthDate cannot be parsed as a DateTime',
        (tester) async {
      // Given — a birthday whose date is a garbage string that DateTime.tryParse returns null for
      final state = HomeState.loaded(
        church: const Church(id: '1', name: 'Igreja', activePlan: 'free'),
        birthdays: [
          BirthdayMember(id: '1', name: 'Zé', birthDate: 'not-a-date'),
        ],
        upcomingEvents: const [],
      );

      // When
      await tester.pumpWidget(buildSubject(state));

      // Then — the avatar still renders with the "--" date placeholder
      expect(find.text('--'), findsOneWidget);
    });

    testWidgets(
        'should render "?" on the avatar circle when a birthday member has an empty name',
        (tester) async {
      // Given — a birthday row whose name is empty. The avatar indexes
      // `member.name[0]`, so without the guard the test would throw.
      final state = HomeState.loaded(
        church: const Church(id: '1', name: 'Igreja', activePlan: 'free'),
        birthdays: [
          BirthdayMember(id: '1', name: '', birthDate: '1990-01-01'),
        ],
        upcomingEvents: const [],
      );

      await tester.pumpWidget(buildSubject(state));

      // The first-name line below the avatar falls back to the empty string,
      // but the avatar letter uses the existing isEmpty → "?" guard.
      expect(tester.takeException(), isNull);
      expect(find.text('?'), findsWidgets);
    });
  });

  group('DashboardPage - Event card date/time formatting', () {
    testWidgets(
        'should render the PT-BR weekday abbreviation and zero-padded time on the event card',
        (tester) async {
      // Given — 2026-04-12 is a Sunday (DateTime.weekday == 7 → 'DOM').
      // Time 07:05 exercises zero padding on both hour and minute.
      final state = HomeState.loaded(
        church: const Church(id: '1', name: 'Igreja', activePlan: 'free'),
        birthdays: const [],
        upcomingEvents: [
          UpcomingEvent(
            id: 'e1',
            title: 'Culto Matutino',
            startsAt: DateTime(2026, 4, 12, 7, 5),
            branchName: 'Sede',
            type: 'SERVICE',
          ),
        ],
      );

      // When
      await tester.pumpWidget(buildSubject(state));

      // Then
      expect(find.text('DOM'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.textContaining('07:05'), findsOneWidget);
    });

    testWidgets(
        'should fall back to "Local a definir" on the event card when branchName is null',
        (tester) async {
      // Given — an event without branchName. The card should NOT render
      // "null" and instead use the PT-BR fallback copy.
      final state = HomeState.loaded(
        church: const Church(id: '1', name: 'Igreja', activePlan: 'free'),
        birthdays: const [],
        upcomingEvents: [
          UpcomingEvent(
            id: 'e1',
            title: 'Culto',
            startsAt: DateTime(2026, 4, 13, 19, 30),
            branchName: null,
            type: 'SERVICE',
          ),
        ],
      );

      await tester.pumpWidget(buildSubject(state));

      expect(find.textContaining('Local a definir'), findsOneWidget);
    });
  });

  group('DashboardPage - Initial state', () {
    testWidgets(
        'should render an empty SizedBox when state is still initial (before loadDashboard completes)',
        (tester) async {
      await tester.pumpWidget(buildSubject(const HomeState.initial()));
      // No content should be visible
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Olá, Ricardo'), findsNothing);
      expect(find.text('Tentar novamente'), findsNothing);
    });
  });
}
