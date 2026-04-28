import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/ebd/data/ebd_repository.dart';
import 'package:atos_logos_mobile/features/ebd/domain/models/ebd_class.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_cubit.dart';
import 'package:atos_logos_mobile/features/ebd/presentation/cubit/ebd_state.dart';

class MockEbdRepository extends Mock implements EbdRepository {}

void main() {
  late MockEbdRepository mockRepository;

  setUp(() {
    mockRepository = MockEbdRepository();
    registerFallbackValue(<EbdLessonInput>[]);
  });

  const classes = [
    EbdClass(id: 'cls-1', churchId: 'c-1', branchId: 'b-1', name: 'Adultos',
        branch: EbdClassBranch(id: 'b-1', name: 'Sede')),
    EbdClass(id: 'cls-2', churchId: 'c-1', branchId: 'b-1', name: 'Jovens',
        branch: EbdClassBranch(id: 'b-1', name: 'Sede')),
  ];

  group('EbdCubit', () {
    test('initial state is EbdState.initial', () {
      final cubit = EbdCubit(repository: mockRepository);
      expect(cubit.state, const EbdState.initial());
      cubit.close();
    });

    blocTest<EbdCubit, EbdState>(
      'emits [loading, loaded] when loadClasses succeeds',
      build: () {
        when(() => mockRepository.getClasses()).thenAnswer((_) async => classes);
        return EbdCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadClasses(),
      expect: () => [
        const EbdState.loading(),
        const EbdState.loaded(classes: classes),
      ],
    );

    blocTest<EbdCubit, EbdState>(
      'emits [loading, error] when loadClasses fails',
      build: () {
        when(() => mockRepository.getClasses()).thenThrow(NetworkException('Erro'));
        return EbdCubit(repository: mockRepository);
      },
      act: (cubit) => cubit.loadClasses(),
      expect: () => [
        const EbdState.loading(),
        const EbdState.error(message: 'Erro'),
      ],
    );

    // ── updateClass ────────────────────────────────────────────────────────

    group('updateClass', () {
      blocTest<EbdCubit, EbdState>(
        'emits [loading, loaded] and returns true when update succeeds',
        build: () {
          when(
            () => mockRepository.updateClass(
              classId: any(named: 'classId'),
              name: any(named: 'name'),
              targetAudience: any(named: 'targetAudience'),
              teacherIds: any(named: 'teacherIds'),
              studentIds: any(named: 'studentIds'),
              lessons: any(named: 'lessons'),
            ),
          ).thenAnswer((_) async {});
          when(() => mockRepository.getClasses())
              .thenAnswer((_) async => classes);
          return EbdCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.updateClass(
          classId: 'cls-1',
          name: 'Adultos Editado',
          targetAudience: 'Adultos',
          teacherIds: ['teacher-1'],
        ),
        expect: () => [
          const EbdState.loading(),
          const EbdState.loaded(classes: classes),
        ],
        verify: (_) {
          verify(
            () => mockRepository.updateClass(
              classId: 'cls-1',
              name: 'Adultos Editado',
              targetAudience: 'Adultos',
              teacherIds: ['teacher-1'],
              studentIds: null,
              lessons: null,
            ),
          ).called(1);
        },
      );

      blocTest<EbdCubit, EbdState>(
        'emits [loading, error] and returns false when update fails',
        build: () {
          when(
            () => mockRepository.updateClass(
              classId: any(named: 'classId'),
              name: any(named: 'name'),
              targetAudience: any(named: 'targetAudience'),
              teacherIds: any(named: 'teacherIds'),
              studentIds: any(named: 'studentIds'),
              lessons: any(named: 'lessons'),
            ),
          ).thenThrow(NetworkException('Erro ao atualizar'));
          return EbdCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.updateClass(
          classId: 'cls-1',
          name: 'Adultos Editado',
          teacherIds: ['teacher-1'],
        ),
        expect: () => [
          const EbdState.loading(),
          const EbdState.error(message: 'Erro ao atualizar'),
        ],
      );

      test('returns true on success', () async {
        when(
          () => mockRepository.updateClass(
            classId: any(named: 'classId'),
            name: any(named: 'name'),
            targetAudience: any(named: 'targetAudience'),
            teacherIds: any(named: 'teacherIds'),
            studentIds: any(named: 'studentIds'),
            lessons: any(named: 'lessons'),
          ),
        ).thenAnswer((_) async {});
        when(() => mockRepository.getClasses())
            .thenAnswer((_) async => classes);

        final cubit = EbdCubit(repository: mockRepository);
        final result = await cubit.updateClass(
          classId: 'cls-1',
          name: 'Adultos Editado',
          teacherIds: ['teacher-1'],
        );

        expect(result, isTrue);
        await cubit.close();
      });

      test('returns false on failure', () async {
        when(
          () => mockRepository.updateClass(
            classId: any(named: 'classId'),
            name: any(named: 'name'),
            targetAudience: any(named: 'targetAudience'),
            teacherIds: any(named: 'teacherIds'),
            studentIds: any(named: 'studentIds'),
            lessons: any(named: 'lessons'),
          ),
        ).thenThrow(NetworkException('Falha'));

        final cubit = EbdCubit(repository: mockRepository);
        final result = await cubit.updateClass(
          classId: 'cls-1',
          name: 'Adultos Editado',
          teacherIds: ['teacher-1'],
        );

        expect(result, isFalse);
        await cubit.close();
      });
    });
  });
}
