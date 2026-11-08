import '../../../core/ui/strings.dart';

/// The small client-side checks the Java sign-in screen also performs.
///
/// Supabase remains the authority. These only catch an empty name, an address
/// with no `@`, or a password shorter than the server's six-character minimum
/// before a network call is made.
abstract final class AuthValidation {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AmpStrings.authNameRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final String email = value == null ? '' : value.trim();
    if (email.isEmpty) {
      return AmpStrings.authEmailRequired;
    }
    final int at = email.indexOf('@');
    if (at <= 0 || at == email.length - 1 || email.contains(' ')) {
      return AmpStrings.authEmailInvalid;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) {
      return AmpStrings.authPasswordTooShort;
    }
    return null;
  }
}
