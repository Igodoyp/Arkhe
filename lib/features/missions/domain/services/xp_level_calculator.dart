// domain/services/xp_level_calculator.dart

// ============================================================================
// XP LEVEL CALCULATOR
// ============================================================================
// Calcula el nivel del usuario basado en XP total acumulado.
// El nivel NO se guarda en DB, se CALCULA dinámicamente desde XP.
//
// REGLA DE PROGRESIÓN:
// - Nivel 1: 0 XP (inicio)
// - Nivel 2: 100 XP
// - Nivel 3: 225 XP (100 + 125)
// - Nivel 4: 375 XP (100 + 125 + 150)
// - Nivel N: suma acumulativa con incremento de +25 XP por nivel
//
// Fórmula: XP requerido para subir del nivel L al L+1 = BASE + (L-1) * INCREMENT
// donde BASE = 100, INCREMENT = 25

class XpLevelCalculator {
  static const int baseXpPerLevel = 100;
  static const int xpIncrementPerLevel = 25;

  /// Calcula el nivel actual basado en XP total
  /// 
  /// Ejemplo:
  /// - 0 XP → Nivel 1
  /// - 150 XP → Nivel 2
  /// - 300 XP → Nivel 3
  int levelForXp(int totalXp) {
    if (totalXp < 0) return 1;
    if (totalXp == 0) return 1;

    int level = 1;
    int xpRequired = 0;

    // Iterar hasta encontrar el nivel correspondiente
    while (xpRequired <= totalXp) {
      final xpForNextLevel = _xpToAdvanceFromLevel(level);
      if (xpRequired + xpForNextLevel > totalXp) {
        break;
      }
      xpRequired += xpForNextLevel;
      level++;
    }

    return level;
  }

  /// XP total requerido para ALCANZAR un nivel específico
  /// 
  /// Ejemplo:
  /// - Nivel 1 → 0 XP
  /// - Nivel 2 → 100 XP
  /// - Nivel 3 → 225 XP
  int xpRequiredForLevel(int level) {
    if (level <= 1) return 0;

    int totalXp = 0;
    for (int i = 1; i < level; i++) {
      totalXp += _xpToAdvanceFromLevel(i);
    }
    return totalXp;
  }

  /// XP necesario para subir AL SIGUIENTE nivel desde el actual XP
  /// 
  /// Ejemplo:
  /// - Con 150 XP (nivel 2) → necesitas 75 XP más para nivel 3
  int xpToNextLevel(int currentXp) {
    final currentLevel = levelForXp(currentXp);
    final xpForNextLevel = xpRequiredForLevel(currentLevel + 1);
    
    return xpForNextLevel - currentXp;
  }

  /// Progreso hacia el siguiente nivel (0.0 a 1.0)
  /// 
  /// Útil para barras de progreso en UI
  /// 
  /// Ejemplo:
  /// - Nivel 2 requiere 100 XP, nivel 3 requiere 225 XP
  /// - Si tienes 150 XP: progreso = (150-100) / (225-100) = 50/125 = 0.4
  double progressToNextLevel(int currentXp) {
    final currentLevel = levelForXp(currentXp);
    final xpForCurrentLevel = xpRequiredForLevel(currentLevel);
    final xpForNextLevel = xpRequiredForLevel(currentLevel + 1);
    
    final xpInCurrentLevel = currentXp - xpForCurrentLevel;
    final xpNeededForLevelUp = xpForNextLevel - xpForCurrentLevel;
    
    if (xpNeededForLevelUp == 0) return 1.0;
    
    return (xpInCurrentLevel / xpNeededForLevelUp).clamp(0.0, 1.0);
  }

  /// XP necesario para subir desde el nivel L al nivel L+1
  /// 
  /// Fórmula: BASE + (L-1) * INCREMENT
  /// - Nivel 1 → 2: 100 XP
  /// - Nivel 2 → 3: 125 XP
  /// - Nivel 3 → 4: 150 XP
  int _xpToAdvanceFromLevel(int level) {
    return baseXpPerLevel + (level - 1) * xpIncrementPerLevel;
  }

  /// Info completa del nivel para mostrar en UI
  LevelInfo getLevelInfo(int totalXp) {
    final level = levelForXp(totalXp);
    final xpForCurrentLevel = xpRequiredForLevel(level);
    final xpForNextLevel = xpRequiredForLevel(level + 1);
    final xpToNext = xpToNextLevel(totalXp);
    final progress = progressToNextLevel(totalXp);

    return LevelInfo(
      level: level,
      totalXp: totalXp,
      xpInCurrentLevel: totalXp - xpForCurrentLevel,
      xpNeededForNextLevel: xpForNextLevel - xpForCurrentLevel,
      xpToNextLevel: xpToNext,
      progressToNextLevel: progress,
    );
  }
}

/// Clase que encapsula toda la info del nivel para mostrar en UI
class LevelInfo {
  final int level;
  final int totalXp;
  final int xpInCurrentLevel;
  final int xpNeededForNextLevel;
  final int xpToNextLevel;
  final double progressToNextLevel;

  LevelInfo({
    required this.level,
    required this.totalXp,
    required this.xpInCurrentLevel,
    required this.xpNeededForNextLevel,
    required this.xpToNextLevel,
    required this.progressToNextLevel,
  });

  @override
  String toString() {
    return 'Level $level (${xpInCurrentLevel}/${xpNeededForNextLevel} XP, ${(progressToNextLevel * 100).toStringAsFixed(1)}%)';
  }
}
