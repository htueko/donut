import 'package:donut/core/formatters/price_mmk_formatter.dart';
import 'package:donut/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceMmkFormatter', () {
    test('formats thousands with separators and MMK suffix', () {
      expect(PriceMmkFormatter.format(3200), '3,200 MMK');
    });

    test('formats amounts over one million', () {
      expect(PriceMmkFormatter.format(1234567), '1,234,567 MMK');
    });

    test('formats zero without separators', () {
      expect(PriceMmkFormatter.format(0), '0 MMK');
    });
  });

  group('Result', () {
    test('success carries its value and reports success', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('failure carries its failure and reports failure', () {
      const result = FailureResult<int>(NotFoundFailure());
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('when routes to the matching branch', () {
      const success = Success<String>('ok');
      const failure = FailureResult<String>(NetworkFailure());

      final successLabel = success.when(
        onSuccess: (value) => 'got $value',
        onFailure: (_) => 'failed',
      );
      final failureLabel = failure.when(
        onSuccess: (value) => 'got $value',
        onFailure: (f) => f.runtimeType.toString(),
      );

      expect(successLabel, 'got ok');
      expect(failureLabel, 'NetworkFailure');
    });

    test('map transforms success values only', () {
      const result = Success<int>(21);
      final mapped = result.map((value) => value * 2);
      expect(mapped.valueOrNull, 42);

      const failure = FailureResult<int>(CacheFailure());
      final mappedFailure = failure.map((value) => value * 2);
      expect(mappedFailure.failureOrNull, isA<CacheFailure>());
    });
  });
}
