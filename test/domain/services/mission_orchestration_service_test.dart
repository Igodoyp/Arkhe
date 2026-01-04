// test/domain/services/mission_orchestration_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:d0/features/missions/domain/entities/mission_entity.dart';
import 'package:d0/features/missions/domain/entities/stat_type.dart';
import 'package:d0/features/missions/domain/services/mission_orchestration_service.dart';
import 'package:d0/features/missions/domain/usecases/get_daily_missions_usecase.dart';
import 'package:d0/features/missions/domain/usecases/generate_daily_missions_usecase.dart';
import 'package:d0/features/missions/data/repositories/mission_repository_impl.dart';
import 'package:d0/core/time/date_time_extensions.dart';
import 'package:d0/core/time/fake_time_provider.dart';

// Mocks
class MockGetDailyMissionsUseCase extends Mock implements GetDailyMissionsUseCase {}
class MockGenerateDailyMissionsUseCase extends Mock implements GenerateDailyMissionsUseCase {}
class MockMissionRepository extends Mock implements MissionRepositoryImpl {}

void main() {
  late MissionOrchestrationService orchestrationService;
  late MockGetDailyMissionsUseCase mockGetMissionsUseCase;
  late MockGenerateDailyMissionsUseCase mockGenerateMissionsUseCase;
  late MockMissionRepository mockMissionRepository;
  late FakeTimeProvider fakeTimeProvider;

  setUp(() {
    mockGetMissionsUseCase = MockGetDailyMissionsUseCase();
    mockGenerateMissionsUseCase = MockGenerateDailyMissionsUseCase();
    mockMissionRepository = MockMissionRepository();
    fakeTimeProvider = FakeTimeProvider(DateTime(2026, 1, 1, 12, 0)); // Fixed date for deterministic tests

    orchestrationService = MissionOrchestrationService(
      getDailyMissionsUseCase: mockGetMissionsUseCase,
      generateDailyMissionsUseCase: mockGenerateMissionsUseCase,
      missionRepository: mockMissionRepository,
      timeProvider: fakeTimeProvider,
    );

    // Register fallback values
    registerFallbackValue(fakeTimeProvider.todayStripped);
  });

  group('MissionOrchestrationService - EAGER Loading', () {
    test('should return existing missions if they exist in Drift', () async {
      // Arrange
      final today = fakeTimeProvider.todayStripped;
      final existingMissions = [
        Mission(
          id: 'm1',
          title: 'Existing Mission',
          description: 'Already in DB',
          type: StatType.strength,
          xpReward: 50,
        ),
      ];

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => existingMissions);

      // Act
      final result = await orchestrationService.eagerLoadTodayMissions();

      // Assert
      expect(result, equals(existingMissions));
      expect(result.length, 1);
      verify(() => mockGetMissionsUseCase(today)).called(1);
      verifyNever(() => mockGenerateMissionsUseCase(any(), persistMissions: any(named: 'persistMissions')));
    });

    test('should generate new missions if none exist in Drift', () async {
      // Arrange
      final today = fakeTimeProvider.todayStripped;
      final generatedMissions = [
        Mission(
          id: 'm1',
          title: 'Generated Mission',
          description: 'Newly created',
          type: StatType.intelligence,
          xpReward: 40,
        ),
      ];

      // Primera llamada: no hay misiones
      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => []);
      
      // Generación exitosa
      when(() => mockGenerateMissionsUseCase(any(), persistMissions: true))
          .thenAnswer((_) async => generatedMissions);

      // Act
      final result = await orchestrationService.eagerLoadTodayMissions();

      // Assert
      expect(result, equals(generatedMissions));
      expect(result.length, 1);
      verify(() => mockGetMissionsUseCase(today)).called(1);
      verify(() => mockGenerateMissionsUseCase(today, persistMissions: true)).called(1);
    });

    test('should return empty list if generation fails', () async {
      // Arrange
      final today = fakeTimeProvider.todayStripped;

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => []);
      
      when(() => mockGenerateMissionsUseCase(any(), persistMissions: true))
          .thenThrow(Exception('Gemini API error'));

      // Act
      final result = await orchestrationService.eagerLoadTodayMissions();

      // Assert
      expect(result, isEmpty);
      verify(() => mockGetMissionsUseCase(today)).called(1);
      verify(() => mockGenerateMissionsUseCase(today, persistMissions: true)).called(1);
    });
  });

  group('MissionOrchestrationService - LAZY Loading', () {
    test('should return existing missions if they exist and forceRegenerate is false', () async {
      // Arrange
      final today = fakeTimeProvider.todayStripped;
      final existingMissions = [
        Mission(
          id: 'm1',
          title: 'Existing',
          description: 'Test',
          type: StatType.vitality,
          xpReward: 30,
        ),
      ];

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => existingMissions);

      // Act
      final result = await orchestrationService.lazyLoadMissions();

      // Assert
      expect(result, equals(existingMissions));
      verify(() => mockGetMissionsUseCase(today)).called(1);
      verifyNever(() => mockMissionRepository.deleteMissionsForDate(any()));
      verifyNever(() => mockGenerateMissionsUseCase(any(), persistMissions: any(named: 'persistMissions')));
    });

    test('should regenerate missions if forceRegenerate is true', () async {
      // Arrange
      final today = fakeTimeProvider.todayStripped;
      final newMissions = [
        Mission(
          id: 'm2',
          title: 'New Mission',
          description: 'Regenerated',
          type: StatType.charisma,
          xpReward: 60,
        ),
      ];

      when(() => mockMissionRepository.deleteMissionsForDate(any()))
          .thenAnswer((_) async => Future.value());
      
      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => []);
      
      when(() => mockGenerateMissionsUseCase(any(), persistMissions: true))
          .thenAnswer((_) async => newMissions);

      // Act
      final result = await orchestrationService.lazyLoadMissions(
        forceRegenerate: true,
      );

      // Assert
      expect(result, equals(newMissions));
      verify(() => mockMissionRepository.deleteMissionsForDate(today)).called(1);
      verify(() => mockGenerateMissionsUseCase(today, persistMissions: true)).called(1);
    });

    test('should generate new missions if none exist', () async {
      // Arrange
      final targetDate = DateTime(2026, 1, 5).stripped;
      final generatedMissions = [
        Mission(
          id: 'm3',
          title: 'Future Mission',
          description: 'For specific date',
          type: StatType.strength,
          xpReward: 50,
        ),
      ];

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => []);
      
      when(() => mockGenerateMissionsUseCase(any(), persistMissions: true))
          .thenAnswer((_) async => generatedMissions);

      // Act
      final result = await orchestrationService.lazyLoadMissions(
        targetDate: targetDate,
      );

      // Assert
      expect(result, equals(generatedMissions));
      verify(() => mockGetMissionsUseCase(targetDate)).called(1);
      verify(() => mockGenerateMissionsUseCase(targetDate, persistMissions: true)).called(1);
    });
  });

  group('MissionOrchestrationService - Helpers', () {
    test('hasMissionsForDate should return true if missions exist', () async {
      // Arrange
      final date = DateTime(2026, 1, 1).stripped;
      final missions = [
        Mission(
          id: 'm1',
          title: 'Test',
          description: 'Test',
          type: StatType.intelligence,
          xpReward: 40,
        ),
      ];

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => missions);

      // Act
      final result = await orchestrationService.hasMissionsForDate(date);

      // Assert
      expect(result, isTrue);
      verify(() => mockGetMissionsUseCase(date)).called(1);
    });

    test('hasMissionsForDate should return false if no missions exist', () async {
      // Arrange
      final date = DateTime(2026, 1, 1).stripped;

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await orchestrationService.hasMissionsForDate(date);

      // Assert
      expect(result, isFalse);
    });

    test('countCompletedMissions should return correct count', () async {
      // Arrange
      final date = DateTime(2026, 1, 1).stripped;
      final missions = [
        Mission(
          id: 'm1',
          title: 'Completed',
          description: 'Test',
          type: StatType.strength,
          xpReward: 50,
          isCompleted: true,
        ),
        Mission(
          id: 'm2',
          title: 'Pending',
          description: 'Test',
          type: StatType.vitality,
          xpReward: 30,
          isCompleted: false,
        ),
        Mission(
          id: 'm3',
          title: 'Also Completed',
          description: 'Test',
          type: StatType.charisma,
          xpReward: 40,
          isCompleted: true,
        ),
      ];

      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => missions);

      // Act
      final result = await orchestrationService.countCompletedMissions(date);

      // Assert
      expect(result, 2);
    });

    test('regenerateMissions should force regeneration', () async {
      // Arrange
      final date = DateTime(2026, 1, 1).stripped;
      final newMissions = [
        Mission(
          id: 'm_new',
          title: 'Regenerated',
          description: 'Test',
          type: StatType.intelligence,
          xpReward: 45,
        ),
      ];

      when(() => mockMissionRepository.deleteMissionsForDate(any()))
          .thenAnswer((_) async => Future.value());
      
      when(() => mockGetMissionsUseCase(any()))
          .thenAnswer((_) async => []);
      
      when(() => mockGenerateMissionsUseCase(any(), persistMissions: true))
          .thenAnswer((_) async => newMissions);

      // Act
      final result = await orchestrationService.regenerateMissions(date);

      // Assert
      expect(result, equals(newMissions));
      verify(() => mockMissionRepository.deleteMissionsForDate(date)).called(1);
      verify(() => mockGenerateMissionsUseCase(date, persistMissions: true)).called(1);
    });
  });
}
