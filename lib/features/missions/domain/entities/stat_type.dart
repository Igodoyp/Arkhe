// Definimos los tipos de atributos posibles.
// Esto evita que escribas "Iteligencia" por error.
enum StatType {
  strength,     // Fuerza (Ej: Hacer ejercicio)
  intelligence, // Inteligencia (Ej: Estudiar)
  creativity,   // Creatividad (Ej: Pintar)
  discipline    // Disciplina (Ej: Tender la cama)
}

// Un pequeño helper para que se vea bonito en la UI luego
extension StatTypeExtension on StatType {
  String get name {
    switch (this) {
      case StatType.strength: return 'Fuerza';
      case StatType.intelligence: return 'Inteligencia';
      case StatType.creativity: return 'Creatividad';
      case StatType.discipline: return 'Disciplina';
    }
  }
}