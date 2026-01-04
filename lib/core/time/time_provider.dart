/// Abstraction for providing time-related functionality.
///
/// This interface allows injecting time dependencies into domain and data layers,
/// enabling deterministic testing without relying on real system time.
///
/// **Design Principle:**
/// Domain and data layers must NEVER call `DateTime.now()` directly.
/// Instead, they should receive a `TimeProvider` and use its methods.
///
/// **Why this matters:**
/// - Tests can mock exact timestamps (e.g., change of day, leap years, midnight edge cases).
/// - Business logic becomes deterministic and reproducible.
/// - No more flaky tests that fail near midnight.
abstract class TimeProvider {
  /// Returns the current instant (with full precision: hours, minutes, seconds, milliseconds).
  ///
  /// Useful for:
  /// - Logging exact timestamps
  /// - Recording `createdAt` / `updatedAt` fields
  /// - Measuring durations
  DateTime get now;

  /// Returns today's date normalized to midnight (00:00:00.000).
  ///
  /// This is the primary method for date-based business logic.
  ///
  /// Example:
  /// ```dart
  /// final today = timeProvider.todayStripped;
  /// // today == DateTime(2026, 1, 1, 0, 0, 0, 0)
  /// ```
  ///
  /// **Guarantee:** Always returns a stripped date (time components = 0).
  DateTime get todayStripped;

  /// Returns yesterday's date normalized to midnight (00:00:00.000).
  ///
  /// Handles edge cases automatically:
  /// - January 1 → December 31 of previous year
  /// - March 1 → February 29 (leap year) or February 28 (non-leap year)
  ///
  /// Example:
  /// ```dart
  /// // When now = DateTime(2026, 1, 1, 12, 34)
  /// final yesterday = timeProvider.yesterdayStripped;
  /// // yesterday == DateTime(2025, 12, 31, 0, 0, 0, 0)
  /// ```
  ///
  /// **Guarantee:** Always returns a stripped date (time components = 0).
  DateTime get yesterdayStripped;

  /// Returns tomorrow's date normalized to midnight (00:00:00.000).
  ///
  /// Handles edge cases automatically:
  /// - December 31 → January 1 of next year
  /// - February 28 (leap year) → February 29
  /// - February 28 (non-leap year) → March 1
  ///
  /// Example:
  /// ```dart
  /// // When now = DateTime(2025, 12, 31, 23, 59)
  /// final tomorrow = timeProvider.tomorrowStripped;
  /// // tomorrow == DateTime(2026, 1, 1, 0, 0, 0, 0)
  /// ```
  ///
  /// **Guarantee:** Always returns a stripped date (time components = 0).
  DateTime get tomorrowStripped;
}
