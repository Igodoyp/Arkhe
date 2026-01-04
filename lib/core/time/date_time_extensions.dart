/// Extension methods for DateTime to handle date normalization.
///
/// This is critical for business logic consistency, especially when dealing
/// with daily sessions and missions that should be grouped by date (not datetime).
extension DateTimeExtensions on DateTime {
  /// Normalizes a DateTime to midnight (00:00:00.000) of the same date.
  ///
  /// This is the **GOLDEN RULE** for all date-based business logic:
  /// - DaySession queries
  /// - Mission scheduling
  /// - Date comparisons in repositories and DAOs
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime(2025, 12, 28, 14, 30, 45, 123);
  /// final stripped = now.stripped;
  /// // stripped == DateTime(2025, 12, 28, 0, 0, 0, 0)
  /// ```
  ///
  /// **Why this matters:**
  /// Without normalization, dates can create phantom duplicates:
  /// - `DateTime(2025, 12, 28, 14, 30)` ≠ `DateTime(2025, 12, 28, 9, 15)`
  /// - But both should map to the same DaySession!
  ///
  /// **Idempotency guarantee:**
  /// Calling `.stripped` multiple times is safe and returns the same value:
  /// ```dart
  /// date.stripped.stripped == date.stripped // Always true
  /// ```
  DateTime get stripped {
    return DateTime(year, month, day);
  }

  /// Alternative name for `.stripped` for code readability in different contexts.
  ///
  /// Use whichever feels more natural in your code:
  /// - `session.date.stripped` (normalize/strip time)
  /// - `targetDate.dateOnly` (get date portion only)
  DateTime get dateOnly => stripped;
}
