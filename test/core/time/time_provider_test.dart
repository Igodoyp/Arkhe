import 'package:d0/core/time/real_time_provider.dart';
import 'package:d0/core/time/fake_time_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeTimeProvider', () {
    test('todayStripped normalizes to midnight', () {
      // Arrange: Fixed time with non-zero hour/minute/second
      final fakeTime = DateTime(2026, 1, 1, 12, 34, 56, 789);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final today = provider.todayStripped;

      // Assert: Should be stripped to midnight
      expect(today, DateTime(2026, 1, 1));
      expect(today.hour, 0);
      expect(today.minute, 0);
      expect(today.second, 0);
      expect(today.millisecond, 0);
      expect(today.microsecond, 0);
    });

    test('yesterdayStripped handles year boundary (Jan 1 -> Dec 31)', () {
      // Arrange: New Year's Day
      final fakeTime = DateTime(2026, 1, 1, 8, 0);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final yesterday = provider.yesterdayStripped;
      final tomorrow = provider.tomorrowStripped;

      // Assert
      expect(yesterday, DateTime(2025, 12, 31));
      expect(tomorrow, DateTime(2026, 1, 2));
      
      // Verify stripped (midnight)
      expect(yesterday.hour, 0);
      expect(yesterday.minute, 0);
      expect(tomorrow.hour, 0);
      expect(tomorrow.minute, 0);
    });

    test('yesterdayStripped handles leap year (Mar 1 2024 -> Feb 29)', () {
      // Arrange: March 1st in a leap year (2024)
      final fakeTime = DateTime(2024, 3, 1, 10, 0);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final yesterday = provider.yesterdayStripped;

      // Assert: Should be February 29 (leap day)
      expect(yesterday, DateTime(2024, 2, 29));
      expect(yesterday.hour, 0);
      expect(yesterday.minute, 0);
      expect(yesterday.second, 0);
    });

    test('yesterdayStripped handles non-leap year (Mar 1 2025 -> Feb 28)', () {
      // Arrange: March 1st in a non-leap year (2025)
      final fakeTime = DateTime(2025, 3, 1, 10, 0);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final yesterday = provider.yesterdayStripped;

      // Assert: Should be February 28 (no leap day)
      expect(yesterday, DateTime(2025, 2, 28));
      expect(yesterday.hour, 0);
      expect(yesterday.minute, 0);
    });

    test('tomorrowStripped handles year boundary (Dec 31 -> Jan 1)', () {
      // Arrange: New Year's Eve
      final fakeTime = DateTime(2025, 12, 31, 23, 59);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final tomorrow = provider.tomorrowStripped;

      // Assert: Should roll over to next year
      expect(tomorrow, DateTime(2026, 1, 1));
      expect(tomorrow.hour, 0);
      expect(tomorrow.minute, 0);
    });

    test('tomorrowStripped handles leap year (Feb 28 2024 -> Feb 29)', () {
      // Arrange: February 28 in a leap year
      final fakeTime = DateTime(2024, 2, 28, 10, 0);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final tomorrow = provider.tomorrowStripped;

      // Assert: Should be February 29
      expect(tomorrow, DateTime(2024, 2, 29));
    });

    test('tomorrowStripped handles non-leap year (Feb 28 2025 -> Mar 1)', () {
      // Arrange: February 28 in a non-leap year
      final fakeTime = DateTime(2025, 2, 28, 10, 0);
      final provider = FakeTimeProvider(fakeTime);

      // Act
      final tomorrow = provider.tomorrowStripped;

      // Assert: Should skip to March 1
      expect(tomorrow, DateTime(2025, 3, 1));
    });

    test('now returns exact fixed time (no stripping)', () {
      // Arrange
      final exactTime = DateTime(2026, 1, 1, 12, 34, 56, 789);
      final provider = FakeTimeProvider(exactTime);

      // Act
      final now = provider.now;

      // Assert: Should preserve all time components
      expect(now, exactTime);
      expect(now.hour, 12);
      expect(now.minute, 34);
      expect(now.second, 56);
      expect(now.millisecond, 789);
    });
  });

  group('RealTimeProvider', () {
    test('todayStripped returns midnight of current date', () {
      // Arrange
      final provider = RealTimeProvider();

      // Act
      final today = provider.todayStripped;
      final now = provider.now;

      // Assert: Should be same date as now, but stripped
      expect(today.year, now.year);
      expect(today.month, now.month);
      expect(today.day, now.day);
      expect(today.hour, 0);
      expect(today.minute, 0);
      expect(today.second, 0);
      expect(today.millisecond, 0);
    });

    test('yesterdayStripped is one day before today', () {
      // Arrange
      final provider = RealTimeProvider();

      // Act
      final today = provider.todayStripped;
      final yesterday = provider.yesterdayStripped;

      // Assert
      final difference = today.difference(yesterday);
      expect(difference.inDays, 1);
      expect(yesterday.hour, 0);
      expect(yesterday.minute, 0);
    });

    test('tomorrowStripped is one day after today', () {
      // Arrange
      final provider = RealTimeProvider();

      // Act
      final today = provider.todayStripped;
      final tomorrow = provider.tomorrowStripped;

      // Assert
      final difference = tomorrow.difference(today);
      expect(difference.inDays, 1);
      expect(tomorrow.hour, 0);
      expect(tomorrow.minute, 0);
    });
  });
}
