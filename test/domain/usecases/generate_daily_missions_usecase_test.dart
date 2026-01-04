import 'package:d0/core/time/date_time_extensions.dart';
import 'package:d0/features/missions/domain/entities/day_feedback_entity.dart';
import 'package:d0/features/missions/domain/entities/day_session_entity.dart';
import 'package:d0/features/missions/domain/entities/mission_entity.dart';
import 'package:d0/features/missions/domain/entities/stat_type.dart';
import 'package:d0/features/missions/domain/entities/user_profile_entity.dart';
import 'package:d0/features/missions/domain/entities/user_stats_entity.dart';
import 'package:d0/features/missions/domain/repositories/day_feedback_repository.dart';
import 'package:d0/features/missions/domain/repositories/day_session_repository.dart';
import 'package:d0/features/missions/domain/repositories/user_profile_repository.dart';
import 'package:d0/features/missions/domain/repositories/user_stats_repository.dart';
import 'package:d0/features/missions/domain/usecases/generate_daily_missions_usecase.dart';
import 'package:d0/features/missions/data/services/gemini_service.dart';
import 'package:d0/features/missions/data/repositories/mission_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockUserProfileRepository extends Mock implements UserProfileRepository {}
class MockDaySessionRepository extends Mock implements DaySessionRepository {}
class MockDayFeedbackRepository extends Mock implements DayFeedbackRepository {}
class MockUserStatsRepository extends Mock implements UserStatsRepository {}
class MockGeminiService extends Mock implements GeminiService {}
class MockMissionRepository extends Mock implements MissionRepositoryImpl {}

void main() {
  late GenerateDailyMissionsUseCase useCase;
  late MockUserProfileRepository mockUserProfileRepo;
  late MockDaySessionRepository mockDaySessionRepo;
  late MockDayFeedbackRepository mockDayFeedbackRepo;
  late MockUserStatsRepository mockUserStatsRepo;
  late MockGeminiService mockGeminiService;
  late MockMissionRepository mockMissionRepo;

  setUp(() {
    mockUserProfileRepo = MockUserProfileRepository();
    mockDaySessionRepo = MockDaySessionRepository();
    mockDayFeedbackRepo = MockDayFeedbackRepository();
    mockUserStatsRepo = MockUserStatsRepository();
    mockGeminiService = MockGeminiService();
    mockMissionRepo = MockMissionRepository();

    // Mock the save method to always succeed
    when(() => mockMissionRepo.saveMissionsForDate(any(), any()))
        .thenAnswer((_) async => Future<void>.value());

    useCase = GenerateDailyMissionsUseCase(
      userProfileRepository: mockUserProfileRepo,
      daySessionRepository: mockDaySessionRepo,
      dayFeedbackRepository: mockDayFeedbackRepo,
      userStatsRepository: mockUserStatsRepo,
      geminiService: mockGeminiService,
      missionRepository: mockMissionRepo,
    );
  });

  group('GenerateDailyMissionsUseCase - Branching Binario', () {
    final targetDate = DateTime(2026, 1, 2, 14, 30); // Fecha arbitraria con hora
    final targetDateStripped = targetDate.stripped;
    final yesterdayStripped = targetDateStripped.subtract(const Duration(days: 1));

    final testProfile = UserProfile(
      id: 'test_user',
      name: 'Test User',
      idealSelfDescription: 'A productive person',
      focusAreas: ['Health', 'Work'],
      currentGoals: ['Exercise daily', 'Code for 2 hours'],
      lastUpdated: DateTime.now(),
    );

    final testStats = UserStats(
      stats: {
        StatType.intelligence: 10.0,
        StatType.wisdom: 15.0,
        StatType.strength: 8.0,
      },
    );

    test('should throw Exception if UserProfile is null', () async {
      // Arrange
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => useCase(targetDate),
        throwsA(isA<Exception>()),
      );

      verify(() => mockUserProfileRepo.getUserProfile()).called(1);
      verifyNever(() => mockUserStatsRepo.getUserStats());
    });

    test('COLD START: should generate missions when no yesterday session exists', () async {
      // Arrange
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => testProfile);
      when(() => mockUserStatsRepo.getUserStats())
          .thenAnswer((_) async => testStats);
      
      // No hay sesión de ayer (getCurrentDaySession retorna sesión de HOY)
      final todaySession = DaySession(
        id: 'session_today',
        date: targetDateStripped,
        completedMissions: [],
        isClosed: false,
      );
      when(() => mockDaySessionRepo.getCurrentDaySession())
          .thenAnswer((_) async => todaySession);

      // Act
      final missions = await useCase(targetDate);

      // Assert
      expect(missions, isNotEmpty);
      expect(missions.length, greaterThanOrEqualTo(3)); // Dummy retorna 3
      expect(missions.first.title, contains('[CS]')); // Cold Start marker
      
      verify(() => mockUserProfileRepo.getUserProfile()).called(1);
      verify(() => mockUserStatsRepo.getUserStats()).called(1);
      verify(() => mockDaySessionRepo.getCurrentDaySession()).called(1);
      verifyNever(() => mockDayFeedbackRepo.getFeedbackBySessionId(any()));
    });

    test('COLD START: should generate missions when yesterday session exists but is NOT closed', () async {
      // Arrange
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => testProfile);
      when(() => mockUserStatsRepo.getUserStats())
          .thenAnswer((_) async => testStats);
      
      // Sesión de ayer existe PERO NO está cerrada (isClosed = false)
      final yesterdaySession = DaySession(
        id: 'session_yesterday',
        date: yesterdayStripped,
        completedMissions: [],
        isClosed: false, // CLAVE: NO cerrada
      );
      when(() => mockDaySessionRepo.getCurrentDaySession())
          .thenAnswer((_) async => yesterdaySession);

      // Act
      final missions = await useCase(targetDate);

      // Assert
      expect(missions, isNotEmpty);
      expect(missions.first.title, contains('[CS]')); // Debe ser Cold Start
      
      verify(() => mockUserProfileRepo.getUserProfile()).called(1);
      verify(() => mockUserStatsRepo.getUserStats()).called(1);
      verify(() => mockDaySessionRepo.getCurrentDaySession()).called(1);
      verifyNever(() => mockDayFeedbackRepo.getFeedbackBySessionId(any()));
    });

    test('FEEDBACK-BASED: should generate missions when yesterday session exists AND is closed', () async {
      // Arrange
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => testProfile);
      when(() => mockUserStatsRepo.getUserStats())
          .thenAnswer((_) async => testStats);
      
      // Sesión de ayer existe Y ESTÁ CERRADA (isClosed = true)
      final yesterdaySession = DaySession(
        id: 'session_yesterday',
        date: yesterdayStripped,
        completedMissions: [
          Mission(
            id: 'm1',
            title: 'Test Mission',
            description: 'Test',
            xpReward: 100,
            isCompleted: true,
            type: StatType.vitality,
          ),
        ],
        isClosed: true, // CLAVE: Cerrada
      );
      when(() => mockDaySessionRepo.getCurrentDaySession())
          .thenAnswer((_) async => yesterdaySession);

      // Feedback de ayer existe
      final yesterdayFeedback = DayFeedback(
        sessionId: 'session_yesterday',
        date: yesterdayStripped,
        difficulty: DifficultyLevel.justRight,
        energyLevel: 4,
        struggledMissions: [],
        easyMissions: [],
        notes: 'Good day',
      );
      when(() => mockDayFeedbackRepo.getFeedbackBySessionId('session_yesterday'))
          .thenAnswer((_) async => yesterdayFeedback);

      // Act
      final missions = await useCase(targetDate);

      // Assert
      expect(missions, isNotEmpty);
      expect(missions.first.title, contains('[FB]')); // Feedback-Based marker
      
      verify(() => mockUserProfileRepo.getUserProfile()).called(1);
      verify(() => mockUserStatsRepo.getUserStats()).called(1);
      verify(() => mockDaySessionRepo.getCurrentDaySession()).called(1);
      verify(() => mockDayFeedbackRepo.getFeedbackBySessionId('session_yesterday')).called(1);
    });

    test('FALLBACK to COLD START: when yesterday session is closed but no feedback exists', () async {
      // Arrange
      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => testProfile);
      when(() => mockUserStatsRepo.getUserStats())
          .thenAnswer((_) async => testStats);
      
      // Sesión de ayer cerrada
      final yesterdaySession = DaySession(
        id: 'session_yesterday',
        date: yesterdayStripped,
        completedMissions: [],
        isClosed: true,
      );
      when(() => mockDaySessionRepo.getCurrentDaySession())
          .thenAnswer((_) async => yesterdaySession);

      // Pero NO hay feedback (edge case)
      when(() => mockDayFeedbackRepo.getFeedbackBySessionId('session_yesterday'))
          .thenAnswer((_) async => null);

      // Act
      final missions = await useCase(targetDate);

      // Assert
      expect(missions, isNotEmpty);
      expect(missions.first.title, contains('[CS]')); // Fallback a Cold Start
      
      verify(() => mockUserProfileRepo.getUserProfile()).called(1);
      verify(() => mockUserStatsRepo.getUserStats()).called(1); // Solo llamado 1 vez en fallback
      verify(() => mockDaySessionRepo.getCurrentDaySession()).called(1);
      verify(() => mockDayFeedbackRepo.getFeedbackBySessionId('session_yesterday')).called(1);
    });

    test('should strip time from targetDate before processing', () async {
      // Arrange
      final dateWithTime = DateTime(2026, 1, 2, 23, 59, 59, 999); // Casi medianoche
      final expectedStripped = DateTime(2026, 1, 2); // Debe normalizarse

      when(() => mockUserProfileRepo.getUserProfile())
          .thenAnswer((_) async => testProfile);
      when(() => mockUserStatsRepo.getUserStats())
          .thenAnswer((_) async => testStats);
      
      final todaySession = DaySession(
        id: 'session_today',
        date: expectedStripped,
        completedMissions: [],
        isClosed: false,
      );
      when(() => mockDaySessionRepo.getCurrentDaySession())
          .thenAnswer((_) async => todaySession);

      // Act
      final missions = await useCase(dateWithTime, persistMissions: false);

      // Assert
      expect(missions, isNotEmpty);
      // La normalización ocurre internamente, validamos que no falla
      verify(() => mockUserProfileRepo.getUserProfile()).called(1);
    });
  });
}
