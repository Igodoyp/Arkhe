import 'package:flutter/services.dart';

/// Servicio para feedback háptico
/// 
/// Centraliza todas las vibraciones de la app para mantener
/// consistencia en la experiencia táctil.
/// 
/// Tipos de feedback según Material Design:
/// - Light: Toque suave (botones, selecciones)
/// - Medium: Toque medio (acciones importantes)
/// - Heavy: Toque fuerte (logros, celebraciones)
/// - Selection: Cambio de selección en listas
/// - Success: Acción completada exitosamente
/// - Warning: Advertencia
/// - Error: Error u operación fallida
class HapticService {
  /// Feedback ligero - Para toques en botones normales
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Feedback medio - Para acciones importantes
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Feedback fuerte - Para logros y celebraciones
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Feedback de selección - Al cambiar items en una lista
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Feedback de éxito - Al completar algo exitosamente
  static Future<void> success() async {
    // Patrón: tap-tap (doble vibración ligera)
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Feedback de celebración - Al completar misión
  static Future<void> celebration() async {
    // Patrón: medium-light-light (triple vibración)
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  /// Feedback de error - Al fallar una operación
  static Future<void> error() async {
    // Patrón: heavy-heavy (doble vibración fuerte)
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Feedback de advertencia - Para alertas
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
  }

  /// Feedback de logro desbloqueado - Para achievements especiales
  static Future<void> achievement() async {
    // Patrón épico: medium-light-medium-heavy
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Feedback para end of day - Ritual especial
  static Future<void> endOfDay() async {
    // Patrón: heavy-pausa-heavy-pausa-heavy
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }
}
