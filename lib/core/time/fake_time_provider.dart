import 'time_provider.dart';
import 'date_time_extensions.dart';

/// Test/fake implementation of [TimeProvider] that allows setting a fixed time.
///
/// This provider is essential for deterministic testing where you need to control
/// the exact date/time used by business logic.
///
/// Example usage in tests:
/// ```dart
/// // Test a scenario on New Year's Day
/// final timeProvider = FakeTimeProvider(DateTime(2026, 1, 1, 12, 34));
/// expect(timeProvider.todayStripped, DateTime(2026, 1, 1));
/// expect(timeProvider.yesterdayStripped, DateTime(2025, 12, 31));
/// expect(timeProvider.tomorrowStripped, DateTime(2026, 1, 2));
///
/// // Test a leap year scenario
/// final leapProvider = FakeTimeProvider(DateTime(2024, 3, 1, 10, 0));
/// expect(leapProvider.yesterdayStripped, DateTime(2024, 2, 29));
/// ```
///
/// **Benefits:**
/// - No flaky tests near midnight
/// - Can test edge cases (year/month boundaries, leap years)
/// - Deterministic and reproducible
class FakeTimeProvider implements TimeProvider {
  /// The fixed time that this provider will return.
  final DateTime _fixedNow;

  /// Creates a fake time provider with a fixed time.
  ///
  /// [fixedNow] The exact date/time to use as "now".
  FakeTimeProvider(DateTime fixedNow) : _fixedNow = fixedNow;

  @override
  DateTime get now => _fixedNow;

  @override
  DateTime get todayStripped => _fixedNow.stripped;

  @override
  DateTime get yesterdayStripped {
    final today = todayStripped;
    return today.subtract(const Duration(days: 1));
  }

  @override
  DateTime get tomorrowStripped {
    final today = todayStripped;
    return today.add(const Duration(days: 1));
  }
}
