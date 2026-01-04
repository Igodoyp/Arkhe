import 'package:flutter_test/flutter_test.dart';
import 'package:d0/core/time/date_time_extensions.dart';

void main() {
  group('DateTimeExtensions.stripped', () {
    test('should normalize DateTime to midnight (00:00:00.000)', () {
      // Arrange
      final dateTime = DateTime(2025, 12, 28, 14, 30, 45, 123, 456);
      
      // Act
      final stripped = dateTime.stripped;
      
      // Assert
      expect(stripped.year, 2025);
      expect(stripped.month, 12);
      expect(stripped.day, 28);
      expect(stripped.hour, 0);
      expect(stripped.minute, 0);
      expect(stripped.second, 0);
      expect(stripped.millisecond, 0);
      expect(stripped.microsecond, 0);
    });

    test('should be idempotent (calling .stripped multiple times returns same value)', () {
      // Arrange
      final dateTime = DateTime(2025, 12, 28, 14, 30, 45);
      
      // Act
      final stripped1 = dateTime.stripped;
      final stripped2 = stripped1.stripped;
      final stripped3 = stripped2.stripped;
      
      // Assert
      expect(stripped1, equals(stripped2));
      expect(stripped2, equals(stripped3));
      expect(stripped1.toIso8601String(), '2025-12-28T00:00:00.000');
    });

    test('should work with DateTime.now()', () {
      // Arrange
      final now = DateTime.now();
      
      // Act
      final stripped = now.stripped;
      
      // Assert
      expect(stripped.year, now.year);
      expect(stripped.month, now.month);
      expect(stripped.day, now.day);
      expect(stripped.hour, 0);
      expect(stripped.minute, 0);
      expect(stripped.second, 0);
    });

    test('should make different times on same day equal', () {
      // Arrange
      final morning = DateTime(2025, 12, 28, 9, 15);
      final afternoon = DateTime(2025, 12, 28, 14, 30);
      final night = DateTime(2025, 12, 28, 23, 59, 59);
      
      // Act
      final morningStripped = morning.stripped;
      final afternoonStripped = afternoon.stripped;
      final nightStripped = night.stripped;
      
      // Assert
      expect(morningStripped, equals(afternoonStripped));
      expect(afternoonStripped, equals(nightStripped));
      expect(morningStripped, equals(nightStripped));
    });

    test('should preserve date boundaries correctly', () {
      // Arrange
      final lastSecondOfDay = DateTime(2025, 12, 28, 23, 59, 59, 999);
      final firstSecondOfNextDay = DateTime(2025, 12, 29, 0, 0, 0, 1);
      
      // Act
      final day1 = lastSecondOfDay.stripped;
      final day2 = firstSecondOfNextDay.stripped;
      
      // Assert
      expect(day1, isNot(equals(day2)));
      expect(day1.toIso8601String(), '2025-12-28T00:00:00.000');
      expect(day2.toIso8601String(), '2025-12-29T00:00:00.000');
    });

    test('should work correctly with leap years', () {
      // Arrange
      final leapDay = DateTime(2024, 2, 29, 12, 30); // 2024 is a leap year
      
      // Act
      final stripped = leapDay.stripped;
      
      // Assert
      expect(stripped.year, 2024);
      expect(stripped.month, 2);
      expect(stripped.day, 29);
      expect(stripped.hour, 0);
      expect(stripped.minute, 0);
      expect(stripped.second, 0);
    });

    test('should work with month boundaries', () {
      // Arrange
      final endOfMonth = DateTime(2025, 1, 31, 23, 59, 59);
      final startOfNextMonth = DateTime(2025, 2, 1, 0, 0, 1);
      
      // Act
      final jan31 = endOfMonth.stripped;
      final feb1 = startOfNextMonth.stripped;
      
      // Assert
      expect(jan31.toIso8601String(), '2025-01-31T00:00:00.000');
      expect(feb1.toIso8601String(), '2025-02-01T00:00:00.000');
      expect(jan31, isNot(equals(feb1)));
    });

    test('dateOnly alias should work identically to stripped', () {
      // Arrange
      final dateTime = DateTime(2025, 12, 28, 14, 30, 45);
      
      // Act
      final stripped = dateTime.stripped;
      final dateOnly = dateTime.dateOnly;
      
      // Assert
      expect(stripped, equals(dateOnly));
      expect(stripped.toIso8601String(), dateOnly.toIso8601String());
    });

    test('should work with UTC dates', () {
      // Arrange
      final utcDateTime = DateTime.utc(2025, 12, 28, 14, 30, 45);
      
      // Act
      final stripped = utcDateTime.stripped;
      
      // Assert
      expect(stripped.year, 2025);
      expect(stripped.month, 12);
      expect(stripped.day, 28);
      expect(stripped.hour, 0);
      expect(stripped.minute, 0);
      expect(stripped.second, 0);
      // Note: stripped creates local DateTime, not UTC
      expect(stripped.isUtc, false);
    });

    test('should allow comparison for DaySession queries', () {
      // Arrange - Simulate two sessions created at different times on same day
      final session1Time = DateTime(2025, 12, 28, 9, 0);
      final session2Time = DateTime(2025, 12, 28, 18, 30);
      final queryTime = DateTime(2025, 12, 28, 12, 15);
      
      // Act
      final session1Date = session1Time.stripped;
      final session2Date = session2Time.stripped;
      final queryDate = queryTime.stripped;
      
      // Assert - All should match for same-day query
      expect(session1Date, equals(queryDate));
      expect(session2Date, equals(queryDate));
      expect(session1Date, equals(session2Date));
    });
  });
}
