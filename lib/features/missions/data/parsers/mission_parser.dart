// data/parsers/mission_parser.dart

import 'dart:convert';
import '../../domain/entities/mission_entity.dart';
import '../../domain/entities/stat_type.dart';

/// Parser para convertir respuestas JSON de Gemini a Mission entities
/// 
/// RESPONSABILIDADES:
/// - Parsear JSON de Gemini a objetos Mission
/// - Validar estructura y tipos de datos
/// - Manejar errores de parsing con mensajes descriptivos
/// 
/// FORMATO ESPERADO DE GEMINI:
/// ```json
/// {
///   "missions": [
///     {
///       "id": "mission_1",
///       "title": "Hacer ejercicio por 30 minutos",
///       "description": "Cardio o fuerza, lo que prefieras",
///       "type": "strength",
///       "xpReward": 50
///     }
///   ]
/// }
/// ```
class MissionParser {
  /// Parsea respuesta JSON de Gemini a lista de Mission entities
  /// 
  /// @param jsonString: String JSON devuelto por Gemini
  /// @returns: Lista de Mission entities listas para persistir
  /// @throws: FormatException si el JSON es inválido
  /// @throws: Exception si faltan campos requeridos
  static List<Mission> parseMissionsFromGemini(String jsonString) {
    try {
      print('[MissionParser] 🔍 Parseando respuesta de Gemini...');
      
      // 1. Parsear JSON string a Map
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      // 2. Validar que existe el array de misiones
      if (!jsonMap.containsKey('missions')) {
        throw Exception('JSON no contiene campo "missions"');
      }
      
      final List<dynamic> missionsJson = jsonMap['missions'];
      
      if (missionsJson.isEmpty) {
        print('[MissionParser] ⚠️ WARNING: Gemini devolvió 0 misiones');
        return [];
      }
      
      // 3. Convertir cada objeto JSON a Mission entity
      final missions = missionsJson.map((missionJson) {
        return _parseSingleMission(missionJson);
      }).toList();
      
      print('[MissionParser] ✅ ${missions.length} misiones parseadas correctamente');
      
      return missions;
    } on FormatException catch (e) {
      print('[MissionParser] ❌ Error de formato JSON: $e');
      throw FormatException('JSON inválido de Gemini: $e');
    } catch (e) {
      print('[MissionParser] ❌ Error al parsear misiones: $e');
      rethrow;
    }
  }

  /// Parsea una sola misión desde JSON
  static Mission _parseSingleMission(Map<String, dynamic> json) {
    // Validar campos requeridos
    _validateRequiredFields(json);
    
    // Parsear tipo de stat
    final StatType statType = _parseStatType(json['type']);
    
    return Mission(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: statType,
      xpReward: json['xpReward'],
      isCompleted: false, // Siempre empieza como no completada
    );
  }

  /// Valida que todos los campos requeridos estén presentes
  static void _validateRequiredFields(Map<String, dynamic> json) {
    final requiredFields = ['id', 'title', 'description', 'type', 'xpReward'];
    
    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        throw Exception('Campo requerido faltante: $field');
      }
    }
    
    // Validar tipos de datos
    if (json['id'] is! String) {
      throw Exception('Campo "id" debe ser String');
    }
    if (json['title'] is! String) {
      throw Exception('Campo "title" debe ser String');
    }
    if (json['description'] is! String) {
      throw Exception('Campo "description" debe ser String');
    }
    if (json['type'] is! String) {
      throw Exception('Campo "type" debe ser String');
    }
    if (json['xpReward'] is! int) {
      throw Exception('Campo "xpReward" debe ser int');
    }
  }

  /// Parsea string de tipo a StatType enum
  /// 
  /// MAPEO:
  /// - "strength" | "fuerza" → StatType.strength
  /// - "intelligence" | "inteligencia" → StatType.intelligence
  /// - "creativity" | "creatividad" → StatType.creativity
  /// - "discipline" | "disciplina" → StatType.discipline
  static StatType _parseStatType(String typeString) {
    final normalizedType = typeString.toLowerCase().trim();
    
    switch (normalizedType) {
      case 'strength':
      case 'fuerza':
        return StatType.strength;
      case 'intelligence':
      case 'inteligencia':
        return StatType.intelligence;
      case 'charisma':
      case 'carisma':
        return StatType.charisma;
      case 'vitality':
      case 'vitalidad':
        return StatType.vitality;
      case 'dexterity':
      case 'destreza':
        return StatType.dexterity;
      case 'wisdom':
      case 'sabiduria':
      case 'sabiduría':
        return StatType.wisdom;
      default:
        print('[MissionParser] ⚠️ Tipo desconocido "$typeString", usando strength por defecto');
        return StatType.strength;
    }
  }

  /// Genera un JSON schema para que Gemini sepa el formato exacto
  /// 
  /// Esto se puede incluir en el prompt para mejorar la precisión
  static String getJsonSchema() {
    return '''
{
  "type": "object",
  "properties": {
    "missions": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": {"type": "string"},
          "title": {"type": "string"},
          "description": {"type": "string"},
          "type": {"type": "string", "enum": ["strength", "intelligence", "creativity", "discipline"]},
          "xpReward": {"type": "integer", "minimum": 10, "maximum": 100}
        },
        "required": ["id", "title", "description", "type", "xpReward"]
      }
    }
  },
  "required": ["missions"]
}
''';
  }
}
