import 'package:flutter/material.dart';

// Definimos los tipos de atributos posibles.
// Sistema de 6 Stats inspirado en RPGs clásicos
enum StatType {
  strength,     // Fuerza (Ej: Ejercicio, trabajo físico)
  intelligence, // Inteligencia (Ej: Estudiar, leer)
  charisma,     // Carisma (Ej: Socializar, networking)
  vitality,     // Vitalidad (Ej: Dormir bien, alimentación)
  dexterity,    // Destreza (Ej: Practicar habilidades, coordinación)
  wisdom        // Sabiduría (Ej: Meditar, reflexionar)
}

// Un pequeño helper para que se vea bonito en la UI luego
extension StatTypeExtension on StatType {
  String get name {
    switch (this) {
      case StatType.strength: return 'Fuerza';
      case StatType.intelligence: return 'Inteligencia';
      case StatType.charisma: return 'Carisma';
      case StatType.vitality: return 'Vitalidad';
      case StatType.dexterity: return 'Destreza';
      case StatType.wisdom: return 'Sabiduría';
    }
  }
  
  /// Icono asociado a cada stat para la UI
  IconData get icon {
    switch (this) {
      case StatType.strength: return Icons.fitness_center;
      case StatType.intelligence: return Icons.school;
      case StatType.charisma: return Icons.people;
      case StatType.vitality: return Icons.favorite;
      case StatType.dexterity: return Icons.sports_esports;
      case StatType.wisdom: return Icons.psychology;
    }
  }
  
  /// Color asociado a cada stat
  Color get color {
    switch (this) {
      case StatType.strength: return const Color(0xFFE53935); // Rojo
      case StatType.intelligence: return const Color(0xFF1E88E5); // Azul
      case StatType.charisma: return const Color(0xFFFDD835); // Amarillo
      case StatType.vitality: return const Color(0xFF43A047); // Verde
      case StatType.dexterity: return const Color(0xFFFF6F00); // Naranja
      case StatType.wisdom: return const Color(0xFF8E24AA); // Púrpura
    }
  }
}