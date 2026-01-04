// domain/usecases/generate_daily_missions_usecase.dart

import '../entities/day_feedback_entity.dart';
import '../entities/day_session_entity.dart';
import '../entities/mission_entity.dart';
import '../entities/stat_type.dart';
import '../entities/user_profile_entity.dart';
import '../entities/user_stats_entity.dart';
import '../repositories/day_feedback_repository.dart';
import '../repositories/day_session_repository.dart';
import '../repositories/user_profile_repository.dart';
import '../repositories/user_stats_repository.dart';
import '../../data/services/gemini_service.dart';
import '../../data/parsers/mission_parser.dart';
import '../../data/repositories/mission_repository_impl.dart';
import '../../../../core/time/date_time_extensions.dart';

/// Use Case para generar misiones diarias con lógica de branching binario
/// 
/// **PLAN MAESTRO - BRANCHING BINARIO:**
/// - Evalúa ESTRICTAMENTE: ¿Existe DaySession para `yesterdayStripped` con `isClosed==true`?
/// - **SI (Feedback-based):** Genera con UserProfile + DayFeedback (ayer) + UserStats
/// - **NO (Cold Start):** Genera con UserProfile + UserStats actuales
/// 
/// NO usa heurísticas intermedias. Es un branching puro basado en `DaySession.isClosed`.
class GenerateDailyMissionsUseCase {
  final UserProfileRepository userProfileRepository;
  final DaySessionRepository daySessionRepository;
  final DayFeedbackRepository dayFeedbackRepository;
  final UserStatsRepository userStatsRepository;
  final GeminiService geminiService;
  final MissionRepositoryImpl missionRepository;

  GenerateDailyMissionsUseCase({
    required this.userProfileRepository,
    required this.daySessionRepository,
    required this.dayFeedbackRepository,
    required this.userStatsRepository,
    required this.geminiService,
    required this.missionRepository,
  });

  /// Genera misiones para una fecha específica Y LAS GUARDA EN DRIFT
  /// 
  /// @param targetDate: Fecha para la cual generar misiones (será stripped internamente)
  /// @param persistMissions: Si true, guarda las misiones en Drift automáticamente (default: true)
  /// @returns: Lista de misiones generadas
  /// @throws: Exception si no hay UserProfile configurado o error en generación
  Future<List<Mission>> call(
    DateTime targetDate, {
    bool persistMissions = true,
  }) async {
    // ========== PASO 0: Normalizar fecha ==========
    final targetDateStripped = targetDate.stripped;
    
    print('[GenerateDailyMissions] 🎯 Generando misiones para: $targetDateStripped');
    
    // ========== PASO 1: Obtener UserProfile (OBLIGATORIO) ==========
    final userProfile = await userProfileRepository.getUserProfile();
    
    if (userProfile == null) {
      throw Exception(
        'No se puede generar misiones sin UserProfile. '
        'El usuario debe completar el onboarding primero.'
      );
    }
    
    print('[GenerateDailyMissions] 👤 UserProfile: ${userProfile.name}');
    
    // ========== PASO 2: Obtener UserStats actuales ==========
    final userStats = await userStatsRepository.getUserStats();
    
    print('[GenerateDailyMissions] 📊 UserStats: ${userStats.toString()}');
    
    // ========== PASO 3: BRANCHING BINARIO (REGLA DE ORO) ==========
    final yesterdayStripped = targetDateStripped.subtract(const Duration(days: 1));
    
    print('[GenerateDailyMissions] 🔍 Buscando DaySession cerrada para: $yesterdayStripped');
    
    // Buscar sesión de ayer
    final yesterdaySession = await _findSessionByDate(yesterdayStripped);
    
    // Evaluar condición binaria: ¿Existe sesión cerrada de ayer?
    final hasFeedbackContext = yesterdaySession != null && yesterdaySession.isClosed;
    
    List<Mission> missions;
    
    if (hasFeedbackContext) {
      print('[GenerateDailyMissions] ✅ FEEDBACK-BASED: Sesión cerrada encontrada (${yesterdaySession.id})');
      missions = await _generateFeedbackBasedMissions(
        targetDateStripped,
        userProfile,
        yesterdaySession,
        userStats,
      );
    } else {
      if (yesterdaySession == null) {
        print('[GenerateDailyMissions] ❄️ COLD START: No hay sesión de ayer');
      } else {
        print('[GenerateDailyMissions] ❄️ COLD START: Sesión de ayer no cerrada (isClosed=${yesterdaySession.isClosed})');
      }
      
      missions = await _generateColdStartMissions(
        targetDateStripped,
        userProfile,
        userStats,
      );
    }
    
    // ========== PASO 4: PERSISTIR MISIONES (OPCIONAL) ==========
    if (persistMissions && missions.isNotEmpty) {
      print('[GenerateDailyMissions] 💾 Guardando ${missions.length} misiones en Drift...');
      await missionRepository.saveMissionsForDate(missions, targetDateStripped);
      print('[GenerateDailyMissions] ✅ Misiones guardadas correctamente');
    }
    
    return missions;
  }

  // ==========================================================================
  // GENERACIÓN FEEDBACK-BASED
  // ==========================================================================
  
  Future<List<Mission>> _generateFeedbackBasedMissions(
    DateTime targetDateStripped,
    UserProfile userProfile,
    DaySession yesterdaySession,
    UserStats userStats,
  ) async {
    print('[GenerateDailyMissions] 📝 Obteniendo feedback de ayer...');
    
    // Obtener el feedback de ayer
    final yesterdayFeedback = await dayFeedbackRepository.getFeedbackBySessionId(
      yesterdaySession.id,
    );
    
    if (yesterdayFeedback == null) {
      print('[GenerateDailyMissions] ⚠️ WARNING: Sesión cerrada pero sin feedback. Usando Cold Start.');
      // Fallback a Cold Start si no hay feedback (edge case)
      return await _generateColdStartMissions(targetDateStripped, userProfile, userStats);
    }
    
    // ========== CONSTRUIR PROMPT FEEDBACK-BASED ==========
    final prompt = _buildFeedbackBasedPrompt(
      userProfile,
      yesterdayFeedback,
      userStats,
      yesterdaySession,
    );
    
    print('[GenerateDailyMissions] 🤖 Prompt Feedback-Based:\n$prompt\n');
    
    // Llamar a Gemini para generar misiones
    try {
      final jsonResponse = await geminiService.generateMissions(prompt);
      final missions = MissionParser.parseMissionsFromGemini(jsonResponse);
      
      print('[GenerateDailyMissions] ✅ ${missions.length} misiones generadas (Feedback-based)');
      return missions;
    } catch (e) {
      print('[GenerateDailyMissions] ❌ Error con Gemini, usando fallback: $e');
      // Fallback a misiones dummy si Gemini falla
      return _getDummyMissions(targetDateStripped, 'feedback');
    }
  }

  // ==========================================================================
  // GENERACIÓN COLD START
  // ==========================================================================
  
  Future<List<Mission>> _generateColdStartMissions(
    DateTime targetDateStripped,
    UserProfile userProfile,
    UserStats userStats,
  ) async {
    // ========== CONSTRUIR PROMPT COLD START ==========
    final prompt = _buildColdStartPrompt(userProfile, userStats);
    
    print('[GenerateDailyMissions] 🤖 Prompt Cold Start:\n$prompt\n');
    
    // Llamar a Gemini para generar misiones
    try {
      final jsonResponse = await geminiService.generateMissions(prompt);
      final missions = MissionParser.parseMissionsFromGemini(jsonResponse);
      
      print('[GenerateDailyMissions] ✅ ${missions.length} misiones generadas (Cold Start)');
      return missions;
    } catch (e) {
      print('[GenerateDailyMissions] ❌ Error con Gemini, usando fallback: $e');
      // Fallback a misiones dummy si Gemini falla
      return _getDummyMissions(targetDateStripped, 'cold');
    }
  }

  // ==========================================================================
  // PROMPT BUILDERS
  // ==========================================================================
  
  String _buildFeedbackBasedPrompt(
    UserProfile userProfile,
    DayFeedback yesterdayFeedback,
    UserStats userStats,
    DaySession yesterdaySession,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('# CONTEXTO: Generación de Misiones Diarias (Feedback-Based)');
    buffer.writeln();
    buffer.writeln('Eres un asistente de productividad experto en gamificación estilo Persona 5.');
    buffer.writeln('Tu tarea es generar misiones diarias personalizadas basadas en:');
    buffer.writeln('1. El perfil ideal del usuario (quién aspira a ser)');
    buffer.writeln('2. El feedback del día anterior (qué funcionó, qué no)');
    buffer.writeln('3. Las estadísticas actuales del usuario');
    buffer.writeln();
    
    // UserProfile
    buffer.writeln('---');
    buffer.writeln(userProfile.toPromptContext());
    buffer.writeln('---');
    buffer.writeln();
    
    // Feedback de ayer
    buffer.writeln('## Feedback del Día Anterior');
    buffer.writeln('Fecha: ${yesterdayFeedback.date}');
    buffer.writeln('Dificultad percibida: ${yesterdayFeedback.difficulty.displayName}');
    buffer.writeln('Nivel de energía: ${yesterdayFeedback.energyLevel}/5');
    buffer.writeln('Misiones completadas: ${yesterdaySession.completedMissions.length}');
    
    if (yesterdayFeedback.struggledMissions.isNotEmpty) {
      buffer.writeln('Misiones difíciles: ${yesterdayFeedback.struggledMissions.length}');
    }
    if (yesterdayFeedback.easyMissions.isNotEmpty) {
      buffer.writeln('Misiones fáciles: ${yesterdayFeedback.easyMissions.length}');
    }
    if (yesterdayFeedback.notes.isNotEmpty) {
      buffer.writeln('Notas del usuario: "${yesterdayFeedback.notes}"');
    }
    buffer.writeln();
    
    // UserStats
    buffer.writeln('## Estadísticas Actuales');
    buffer.writeln(userStats.toString());
    buffer.writeln();
    
    // Instrucciones
    buffer.writeln('---');
    buffer.writeln('## INSTRUCCIONES:');
    buffer.writeln('- Genera 3-5 misiones equilibradas para HOY');
    buffer.writeln('- AJUSTA la dificultad según el feedback de ayer:');
    buffer.writeln('  * Si fue "Muy Difícil" o energía ≤2: Reduce carga');
    buffer.writeln('  * Si fue "Muy Fácil": Aumenta desafío');
    buffer.writeln('  * Si fue "Perfecto": Mantén nivel similar');
    buffer.writeln('- Usa el Ideal Self como brújula para los tipos de misiones');
    buffer.writeln('- Distribuye entre stats: Intelligence, Discipline, Strength');
    buffer.writeln();
    buffer.writeln('## FORMATO DE RESPUESTA (JSON):');
    buffer.writeln(MissionParser.getJsonSchema());
    buffer.writeln();
    
    return buffer.toString();
  }

  String _buildColdStartPrompt(
    UserProfile userProfile,
    UserStats userStats,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('# CONTEXTO: Generación de Misiones Diarias (Cold Start)');
    buffer.writeln();
    buffer.writeln('Eres un asistente de productividad experto en gamificación estilo Persona 5.');
    buffer.writeln('Tu tarea es generar misiones diarias personalizadas basadas en:');
    buffer.writeln('1. El perfil ideal del usuario (quién aspira a ser)');
    buffer.writeln('2. Las estadísticas actuales del usuario');
    buffer.writeln();
    
    // UserProfile
    buffer.writeln('---');
    buffer.writeln(userProfile.toPromptContext());
    buffer.writeln('---');
    buffer.writeln();
    
    // UserStats
    buffer.writeln('## Estadísticas Actuales');
    buffer.writeln(userStats.toString());
    buffer.writeln();
    
    // Instrucciones
    buffer.writeln('---');
    buffer.writeln('## INSTRUCCIONES:');
    buffer.writeln('- Genera 3-5 misiones equilibradas para HOY');
    buffer.writeln('- Este es el PRIMER DÍA (o no hay feedback previo)');
    buffer.writeln('- Comienza con dificultad MODERADA (ni muy fácil, ni abrumador)');
    buffer.writeln('- Usa el Ideal Self como guía para los tipos de misiones');
    buffer.writeln('- Distribuye entre stats: Intelligence, Discipline, Strength');
    buffer.writeln('- Las misiones deben ser ESPECÍFICAS y MEDIBLES');
    buffer.writeln();
    buffer.writeln('## FORMATO DE RESPUESTA (JSON):');
    buffer.writeln(MissionParser.getJsonSchema());
    buffer.writeln();
    
    return buffer.toString();
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================
  
  /// Busca una sesión por fecha específica
  /// 
  /// NOTA: Esto es un placeholder. En la implementación real con Drift,
  /// tendrás un método `getSessionByDate(DateTime date)` en el repository.
  Future<DaySession?> _findSessionByDate(DateTime dateStripped) async {
    // TODO: Implementar búsqueda real en Drift
    // return await daySessionRepository.getSessionByDate(dateStripped);
    
    // Por ahora, solo chequeamos la sesión actual
    final currentSession = await daySessionRepository.getCurrentDaySession();
    
    if (currentSession.date == dateStripped) {
      return currentSession;
    }
    
    return null; // No encontrada
  }

  /// Genera misiones dummy para testing (placeholder para Gemini)
  List<Mission> _getDummyMissions(DateTime targetDate, String context) {
    final prefix = context == 'feedback' ? '[FB]' : '[CS]';
    
    return [
      Mission(
        id: 'mission_${targetDate.millisecondsSinceEpoch}_1',
        title: '$prefix Protocolo Pomodoro',
        description: 'Completa 3 ciclos de 25 minutos de trabajo enfocado',
        xpReward: 120,
        isCompleted: false,
        type: StatType.intelligence,
      ),
      Mission(
        id: 'mission_${targetDate.millisecondsSinceEpoch}_2',
        title: '$prefix Rutina Matutina',
        description: 'Levántate a las 6:30 AM y completa tu rutina matutina',
        xpReward: 80,
        isCompleted: false,
        type: StatType.vitality,
      ),
      Mission(
        id: 'mission_${targetDate.millisecondsSinceEpoch}_3',
        title: '$prefix Ejercicio Diario',
        description: '30 minutos de ejercicio cardiovascular',
        xpReward: 100,
        isCompleted: false,
        type: StatType.strength,
      ),
    ];
  }
}
