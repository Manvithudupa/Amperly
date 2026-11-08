import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/features/auth/application/auth_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('name', () {
    test('requires a non-empty display name', () {
      expect(AuthValidation.name(null), AmpStrings.authNameRequired);
      expect(AuthValidation.name('   '), AmpStrings.authNameRequired);
      expect(AuthValidation.name('Asha Rao'), isNull);
    });
  });

  group('email', () {
    test('rejects an empty or malformed address', () {
      expect(AuthValidation.email(null), AmpStrings.authEmailRequired);
      expect(AuthValidation.email('  '), AmpStrings.authEmailRequired);
      expect(AuthValidation.email('asha'), AmpStrings.authEmailInvalid);
      expect(AuthValidation.email('@example.com'), AmpStrings.authEmailInvalid);
      expect(AuthValidation.email('asha@'), AmpStrings.authEmailInvalid);
      expect(
        AuthValidation.email('asha @example.com'),
        AmpStrings.authEmailInvalid,
      );
    });

    test('accepts an address with both parts and trims it', () {
      expect(AuthValidation.email('asha@example.com'), isNull);
      expect(AuthValidation.email('  asha@example.com  '), isNull);
    });
  });

  group('password', () {
    test('matches the server minimum of six characters', () {
      expect(AuthValidation.password(null), AmpStrings.authPasswordTooShort);
      expect(AuthValidation.password('12345'), AmpStrings.authPasswordTooShort);
      expect(AuthValidation.password('123456'), isNull);
    });
  });
}
