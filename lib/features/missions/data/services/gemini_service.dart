// data/services/gemini_service.dart

import 'package:google_generative_ai/google_generative_ai.dart';

/// Servicio para comunicación con Gemini API
/// 
/// RESPONSABILIDADES:
/// - Enviar prompts a Gemini
/// - Recibir respuestas JSON estructuradas
/// - Manejar errores de API
/// 
/// CONFIGURACIÓN:
/// - Modelo: gemini-1.5-flash (rápido y económico para tasks diarias)
/// - Temperature: 0.7 (balance entre creatividad y consistencia)
/// - Response format: JSON
class GeminiService {
  final GenerativeModel _model;
  final String _apiKey;
  
  GeminiService({required String apiKey})
      : _apiKey = apiKey,
        _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 2048,
            responseMimeType: 'application/json',
          ),
          systemInstruction: Content.system(
            'Eres un asistente de productividad experto en gamificación estilo Persona 5. '
            'Tu tarea es generar misiones diarias personalizadas y estructuradas. '
            'SIEMPRE responde en formato JSON válido.'
          ),
        );

  /// Genera misiones diarias basadas en un prompt
  /// 
  /// @param prompt: Prompt construido con contexto del usuario
  /// @returns: String JSON con array de misiones
  /// @throws: Exception si la API falla o responde con formato inválido
  Future<String> generateMissions(String prompt) async {
    try {
      print('[GeminiService] 📤 Enviando prompt a Gemini...');
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini devolvió respuesta vacía');
      }
      
      final jsonResponse = response.text!.trim();
      print('[GeminiService] 📥 Respuesta recibida: ${jsonResponse.length} caracteres');
      
      return jsonResponse;
    } catch (e) {
      print('[GeminiService] ❌ Error al generar misiones: $e');
      // Intentar listar modelos disponibles para debug
      await listAvailableModels();
      rethrow;
    }
  }

  /// Lista los modelos disponibles para la API Key actual
  Future<void> listAvailableModels() async {
    try {
      // Nota: El SDK de Dart no expone listModels directamente en GenerativeModel
      // pero podemos intentar inferirlo o usar un cliente HTTP crudo si fuera necesario.
      // Sin embargo, el error sugiere llamar a ListModels.
      // Como el SDK actual es limitado, imprimiremos un mensaje de ayuda.
      print('[GeminiService] ℹ️ Para ver los modelos disponibles, visita: https://aistudio.google.com/app/apikey');
      print('[GeminiService] ℹ️ O usa curl: curl https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey');
    } catch (e) {
      print('[GeminiService] Error al listar modelos: $e');
    }
  }

  /// Genera feedback personalizado basado en el desempeño del día
  /// 
  /// @param prompt: Prompt con contexto del feedback del usuario
  /// @returns: String JSON con análisis y sugerencias
  Future<String> generateFeedbackAnalysis(String prompt) async {
    try {
      print('[GeminiService] 📤 Enviando prompt de feedback a Gemini...');
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini devolvió respuesta vacía para feedback');
      }
      
      final jsonResponse = response.text!.trim();
      print('[GeminiService] 📥 Feedback recibido: ${jsonResponse.length} caracteres');
      
      return jsonResponse;
    } catch (e) {
      print('[GeminiService] ❌ Error al generar feedback: $e');
      rethrow;
    }
  }

  /// Valida que el servicio esté configurado correctamente
  /// 
  /// Hace una llamada simple a la API para verificar conectividad
  Future<bool> validateConnection() async {
    try {
      final testPrompt = '¿Estás listo para generar misiones? Responde solo "ready" en JSON: {"status": "ready"}';
      final response = await generateMissions(testPrompt);
      return response.contains('ready');
    } catch (e) {
      print('[GeminiService] ⚠️ Validación falló: $e');
      return false;
    }
  }
}
