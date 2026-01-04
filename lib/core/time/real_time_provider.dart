import 'time_provider.dart';
import 'date_time_extensions.dart';

/// Production implementation of [TimeProvider] that uses system time.
///
/// This provider delegates to `DateTime.now()` to get the real current time.
///
/// Example usage:
/// ```dart
/// final timeProvider = RealTimeProvider();
/// final today = timeProvider.todayStripped;
/// ```
///
/// **For testing:**
/// Use [FakeTimeProvider] instead to mock specific dates/times.
class RealTimeProvider implements TimeProvider {
  @override
  DateTime get now => DateTime.now();

  @override
  DateTime get todayStripped => now.stripped;

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
