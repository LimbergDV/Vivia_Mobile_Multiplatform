import 'package:flutter_test/flutter_test.dart';
import 'package:vivia_mobile/core/utils/input_validators.dart';

void main() {
  group('InputValidators.email', () {
    test('accepts valid addresses including long TLDs and plus tags', () {
      expect(InputValidators.email('user@example.com'), isNull);
      expect(InputValidators.email('user+tag@sub.domain.online'), isNull);
    });

    test('rejects malformed or empty addresses', () {
      expect(InputValidators.email(''), isNotNull);
      expect(InputValidators.email('nope'), isNotNull);
      expect(InputValidators.email('a@b'), isNotNull);
      expect(InputValidators.email('a b@c.com'), isNotNull);
    });
  });

  group('InputValidators.requiredField', () {
    test('rejects blank or whitespace-only', () {
      expect(InputValidators.requiredField(''), isNotNull);
      expect(InputValidators.requiredField('   '), isNotNull);
    });

    test('accepts non-blank', () {
      expect(InputValidators.requiredField('x'), isNull);
    });
  });

  group('InputValidators.password', () {
    test('enforces min and max length', () {
      expect(InputValidators.password('short'), isNotNull);
      expect(InputValidators.password('a' * 41), isNotNull);
      expect(InputValidators.password('goodpass1'), isNull);
    });
  });

  group('InputValidators.phone', () {
    test('requires exactly 10 digits', () {
      expect(InputValidators.phone('123456789'), isNotNull);
      expect(InputValidators.phone('12345678901'), isNotNull);
      expect(InputValidators.phone('9274577845'), isNull);
    });
  });

  group('InputValidators.name', () {
    test('rejects empty and over-long values', () {
      expect(InputValidators.name(''), isNotNull);
      expect(InputValidators.name('a' * 51), isNotNull);
      expect(InputValidators.name('Limberg'), isNull);
    });
  });
}
