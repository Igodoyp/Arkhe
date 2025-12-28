// presentation/controllers/bonfire_controller.dart

// ============================================================================
// CONTROLLER: BONFIRE (HOGUERA)
// ============================================================================
// Controlador para la pantalla de Bonfire (inspirada en Dark Souls).
// Gestiona el estado del feedback del usuario y coordina con los use cases.
//
// RESPONSABILIDADES:
// - Gestionar el estado del formulario de feedback
// - Validar y guardar el feedback del usuario
// - Coordinar con DaySessionController para obtener datos de la sesión
// - Generar prompts para IA basados en el feedback
// - Mostrar análisis y tendencias al usuario

import 'package:flutter/foundation.dart';
import '../../domain/entities/day_feedback_entity.dart';
import '../../domain/usecases/day_feedback_usecase.dart';

/// Estados posibles del Bonfire Controller
enum BonfireState {
  /// Inicializando, cargando datos de la sesión
  initial,
  
  /// Listo para recopilar feedback del usuario
  ready,
  
  /// Guardando el feedback
  saving,
  
  /// Feedback guardado exitosamente
  saved,
  
  /// Error al procesar el feedback
  error,
}

/// Controller para la pantalla de Bonfire (feedback del día)
class BonfireController extends ChangeNotifier {
  // ========== Dependencias ==========
  final SaveFeedbackUseCase saveFeedbackUseCase;
  final GetFeedbackHistoryUseCase getFeedbackHistoryUseCase;
  final AnalyzeFeedbackTrendsUseCase analyzeFeedbackTrendsUseCase;
  final GenerateAIPromptUseCase generateAIPromptUseCase;

  // ========== Estado ==========
  BonfireState _state = BonfireState.initial;
  String? _errorMessage;

  // Datos de la sesión actual (recibidos desde DaySessionController)
  String? _sessionId;
  List<String>? _completedMissionIds;

  // Datos del formulario de feedback
  DifficultyLevel _selectedDifficulty = DifficultyLevel.justRight;
  int _selectedEnergy = 3;
  final Set<String> _struggledMissions = {};
  final Set<String> _easyMissions = {};
  String _notes = '';

  // Análisis de tendencias (opcional, para mostrar al usuario)
  FeedbackAnalysis? _analysis;

  // ========== Constructor ==========
  BonfireController({
    required this.saveFeedbackUseCase,
    required this.getFeedbackHistoryUseCase,
    required this.analyzeFeedbackTrendsUseCase,
    required this.generateAIPromptUseCase,
  });

  // ========== Getters ==========
  BonfireState get state => _state;
  String? get errorMessage => _errorMessage;
  DifficultyLevel get selectedDifficulty => _selectedDifficulty;
  int get selectedEnergy => _selectedEnergy;
  Set<String> get struggledMissions => Set.unmodifiable(_struggledMissions);
  Set<String> get easyMissions => Set.unmodifiable(_easyMissions);
  String get notes => _notes;
  FeedbackAnalysis? get analysis => _analysis;

  bool get isReady => _state == BonfireState.ready;
  bool get isSaving => _state == BonfireState.saving;
  bool get isSaved => _state == BonfireState.saved;
  bool get hasError => _state == BonfireState.error;

  // ========== Inicialización ==========

  /// Inicializa el controller con datos de la sesión del día
  /// Debe ser llamado al entrar a la pantalla de Bonfire
  Future<void> initialize({
    required String sessionId,
    required List<String> completedMissionIds,
  }) async {
    print('[BonfireController] 🔥 Inicializando Bonfire...');
    print('  - Session ID: $sessionId');
    print('  - Misiones completadas: ${completedMissionIds.length}');

    _sessionId = sessionId;
    _completedMissionIds = completedMissionIds;

    // Resetear datos del formulario
    _resetForm();

    // Cargar análisis de tendencias (opcional, para contexto)
    await _loadAnalysis();

    _state = BonfireState.ready;
    notifyListeners();

    print('[BonfireController] ✅ Bonfire listo para feedback');
  }

  void _resetForm() {
    _selectedDifficulty = DifficultyLevel.justRight;
    _selectedEnergy = 3;
    _struggledMissions.clear();
    _easyMissions.clear();
    _notes = '';
    _errorMessage = null;
  }

  Future<void> _loadAnalysis() async {
    try {
      _analysis = await analyzeFeedbackTrendsUseCase(lastDays: 7);
      print('[BonfireController] 📊 Análisis cargado: $_analysis');
    } catch (e) {
      print('[BonfireController] ⚠️ No se pudo cargar análisis: $e');
      // No es crítico, continuar sin análisis
    }
  }

  // ========== Actualización de Formulario ==========

  /// Actualiza el nivel de dificultad seleccionado
  void setDifficulty(DifficultyLevel difficulty) {
    if (_state != BonfireState.ready) return;

    _selectedDifficulty = difficulty;
    notifyListeners();
    print('[BonfireController] 📊 Dificultad actualizada: ${difficulty.displayName}');
  }

  /// Actualiza el nivel de energía (1-5)
  void setEnergy(int energy) {
    if (_state != BonfireState.ready) return;
    if (energy < 1 || energy > 5) {
      print('[BonfireController] ⚠️ Energía inválida: $energy (debe ser 1-5)');
      return;
    }

    _selectedEnergy = energy;
    notifyListeners();
    print('[BonfireController] ⚡ Energía actualizada: $energy/5');
  }

  /// Marca/desmarca una misión como difícil
  void toggleStruggledMission(String missionId) {
    if (_state != BonfireState.ready) return;

    if (_struggledMissions.contains(missionId)) {
      _struggledMissions.remove(missionId);
    } else {
      _struggledMissions.add(missionId);
      // Si está marcada como fácil, quitarla de ahí
      _easyMissions.remove(missionId);
    }

    notifyListeners();
    print('[BonfireController] 🔴 Misiones difíciles: ${_struggledMissions.length}');
  }

  /// Marca/desmarca una misión como fácil
  void toggleEasyMission(String missionId) {
    if (_state != BonfireState.ready) return;

    if (_easyMissions.contains(missionId)) {
      _easyMissions.remove(missionId);
    } else {
      _easyMissions.add(missionId);
      // Si está marcada como difícil, quitarla de ahí
      _struggledMissions.remove(missionId);
    }

    notifyListeners();
    print('[BonfireController] 🟢 Misiones fáciles: ${_easyMissions.length}');
  }

  /// Actualiza las notas del usuario
  void setNotes(String notes) {
    if (_state != BonfireState.ready) return;

    _notes = notes;
    // No notificar por cada tecla, solo guardar el valor
    print('[BonfireController] 📝 Notas actualizadas (${notes.length} caracteres)');
  }

  // ========== Guardado de Feedback ==========

  /// Guarda el feedback del usuario
  /// Retorna true si se guardó exitosamente, false en caso contrario
  Future<bool> saveFeedback() async {
    if (_sessionId == null) {
      _setError('No hay una sesión activa');
      return false;
    }

    print('[BonfireController] 💾 Guardando feedback...');
    _state = BonfireState.saving;
    _errorMessage = null;
    notifyListeners();

    try {
      // Crear entidad de feedback
      final feedback = DayFeedback(
        sessionId: _sessionId!,
        date: DateTime.now(),
        difficulty: _selectedDifficulty,
        energyLevel: _selectedEnergy,
        struggledMissions: _struggledMissions.toList(),
        easyMissions: _easyMissions.toList(),
        notes: _notes,
      );

      // Guardar usando el use case
      await saveFeedbackUseCase(feedback);

      _state = BonfireState.saved;
      notifyListeners();

      print('[BonfireController] ✅ Feedback guardado exitosamente');
      return true;
    } catch (e) {
      _setError('Error al guardar feedback: $e');
      return false;
    }
  }

  void _setError(String message) {
    print('[BonfireController] ❌ Error: $message');
    _errorMessage = message;
    _state = BonfireState.error;
    notifyListeners();
  }

  // ========== Generación de Prompt para IA ==========

  /// Genera un prompt para la IA basado en el historial de feedbacks
  /// Útil para generar misiones adaptativas en el futuro
  Future<String?> generateAIPrompt() async {
    try {
      print('[BonfireController] 🤖 Generando prompt para IA...');
      final prompt = await generateAIPromptUseCase(basedOnLastDays: 7);
      print('[BonfireController] ✅ Prompt generado exitosamente');
      return prompt;
    } catch (e) {
      print('[BonfireController] ❌ Error al generar prompt: $e');
      return null;
    }
  }

  // ========== Historial y Análisis ==========

  /// Obtiene el historial completo de feedbacks
  Future<List<DayFeedback>> getHistory() async {
    try {
      return await getFeedbackHistoryUseCase.getAllFeedbacks();
    } catch (e) {
      print('[BonfireController] ❌ Error al obtener historial: $e');
      return [];
    }
  }

  /// Recarga el análisis de tendencias
  Future<void> refreshAnalysis() async {
    await _loadAnalysis();
    notifyListeners();
  }

  // ========== Helpers de Validación ==========

  /// Verifica si hay suficientes datos para guardar
  bool get canSave => _sessionId != null && _state == BonfireState.ready;

  /// Obtiene un resumen del feedback actual (para preview)
  Map<String, dynamic> get feedbackSummary => {
    'difficulty': _selectedDifficulty.displayName,
    'energy': '$_selectedEnergy/5',
    'struggledMissions': _struggledMissions.length,
    'easyMissions': _easyMissions.length,
    'hasNotes': _notes.isNotEmpty,
  };

  // ========== Cleanup ==========

  /// Resetea el estado del controller (útil al salir de la pantalla)
  void reset() {
    print('[BonfireController] 🔄 Reseteando Bonfire Controller');
    _sessionId = null;
    _completedMissionIds = null;
    _resetForm();
    _analysis = null;
    _state = BonfireState.initial;
    notifyListeners();
  }

  @override
  void dispose() {
    print('[BonfireController] 🗑️ Disposing Bonfire Controller');
    super.dispose();
  }
}
