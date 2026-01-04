// test/data/parsers/mission_parser_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:d0/features/missions/data/parsers/mission_parser.dart';
import 'package:d0/features/missions/domain/entities/mission_entity.dart';
import 'package:d0/features/missions/domain/entities/stat_type.dart';

void main() {
  group('MissionParser', () {
    test('should parse valid JSON from Gemini', () {
      // Arrange
      const jsonString = '''
{
  "missions": [
    {
      "id": "mission_1",
      "title": "Hacer ejercicio por 30 minutos",
      "description": "Cardio o fuerza, lo que prefieras",
      "type": "strength",
      "xpReward": 50
    },
    {
      "id": "mission_2",
      "title": "Leer 20 páginas de un libro",
      "description": "Continúa con tu lectura actual",
      "type": "intelligence",
      "xpReward": 40
    }
  ]
}
''';

      // Act
      final missions = MissionParser.parseMissionsFromGemini(jsonString);

      // Assert
      expect(missions, hasLength(2));
      
      expect(missions[0].id, 'mission_1');
      expect(missions[0].title, 'Hacer ejercicio por 30 minutos');
      expect(missions[0].type, StatType.strength);
      expect(missions[0].xpReward, 50);
      expect(missions[0].isCompleted, false);
      
      expect(missions[1].id, 'mission_2');
      expect(missions[1].type, StatType.intelligence);
    });

    test('should parse Spanish stat types', () {
      // Arrange
      const jsonString = '''
{
  "missions": [
    {
      "id": "m1",
      "title": "Test",
      "description": "Test",
      "type": "fuerza",
      "xpReward": 50
    },
    {
      "id": "m2",
      "title": "Test",
      "description": "Test",
      "type": "inteligencia",
      "xpReward": 50
    },
    {
      "id": "m3",
      "title": "Test",
      "description": "Test",
      "type": "carisma",
      "xpReward": 50
    },
    {
      "id": "m4",
      "title": "Test",
      "description": "Test",
      "type": "sabiduria",
      "xpReward": 50
    }
  ]
}
''';

      // Act
      final missions = MissionParser.parseMissionsFromGemini(jsonString);

      // Assert
      expect(missions[0].type, StatType.strength);
      expect(missions[1].type, StatType.intelligence);
      expect(missions[2].type, StatType.charisma);
      expect(missions[3].type, StatType.wisdom);
    });

    test('should throw FormatException on invalid JSON', () {
      // Arrange
      const invalidJson = 'esto no es JSON válido {';

      // Act & Assert
      expect(
        () => MissionParser.parseMissionsFromGemini(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('should throw Exception if "missions" key is missing', () {
      // Arrange
      const jsonString = '''
{
  "data": []
}
''';

      // Act & Assert
      expect(
        () => MissionParser.parseMissionsFromGemini(jsonString),
        throwsException,
      );
    });

    test('should throw Exception if required field is missing', () {
      // Arrange
      const jsonString = '''
{
  "missions": [
    {
      "id": "m1",
      "title": "Test"
    }
  ]
}
''';

      // Act & Assert
      expect(
        () => MissionParser.parseMissionsFromGemini(jsonString),
        throwsException,
      );
    });

    test('should throw Exception if field has wrong type', () {
      // Arrange
      const jsonString = '''
{
  "missions": [
    {
      "id": "m1",
      "title": "Test",
      "description": "Test",
      "type": "strength",
      "xpReward": "not a number"
    }
  ]
}
''';

      // Act & Assert
      expect(
        () => MissionParser.parseMissionsFromGemini(jsonString),
        throwsException,
      );
    });

    test('should return empty list if missions array is empty', () {
      // Arrange
      const jsonString = '''
{
  "missions": []
}
''';

      // Act
      final missions = MissionParser.parseMissionsFromGemini(jsonString);

      // Assert
      expect(missions, isEmpty);
    });

    test('should default to strength for unknown stat types', () {
      // Arrange
      const jsonString = '''
{
  "missions": [
    {
      "id": "m1",
      "title": "Test",
      "description": "Test",
      "type": "unknown_type",
      "xpReward": 50
    }
  ]
}
''';

      // Act
      final missions = MissionParser.parseMissionsFromGemini(jsonString);

      // Assert
      expect(missions[0].type, StatType.strength);
    });

    test('should handle case-insensitive stat types', () {
      // Arrange
      const jsonString = '''
{
  "missions": [
    {
      "id": "m1",
      "title": "Test",
      "description": "Test",
      "type": "STRENGTH",
      "xpReward": 50
    },
    {
      "id": "m2",
      "title": "Test",
      "description": "Test",
      "type": "Intelligence",
      "xpReward": 50
    }
  ]
}
''';

      // Act
      final missions = MissionParser.parseMissionsFromGemini(jsonString);

      // Assert
      expect(missions[0].type, StatType.strength);
      expect(missions[1].type, StatType.intelligence);
    });
  });
}
