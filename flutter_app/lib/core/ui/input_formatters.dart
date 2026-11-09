import 'package:flutter/services.dart';

/// Input filters shared by the forms.
///
/// These only keep impossible characters out of the box. The domain validators
/// still decide whether a value is in range, so the keyboard can never make an
/// invalid value look valid.
abstract final class AmpInputFormatters {
  /// Digits with at most one decimal point and three places.
  static final List<TextInputFormatter> decimal =
      List<TextInputFormatter>.unmodifiable(<TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        TextInputFormatter.withFunction((
          TextEditingValue oldValue,
          TextEditingValue newValue,
        ) {
          if (newValue.text.isEmpty ||
              RegExp(r'^\d*\.?\d{0,3}$').hasMatch(newValue.text)) {
            return newValue;
          }
          return oldValue;
        }),
      ]);

  /// Whole numbers only.
  static final TextInputFormatter digits =
      FilteringTextInputFormatter.digitsOnly;

  /// Registration plates use uppercase letters, digits, spaces and hyphens.
  static final TextInputFormatter registration =
      TextInputFormatter.withFunction((
        TextEditingValue oldValue,
        TextEditingValue newValue,
      ) {
        final String upper = newValue.text.toUpperCase();
        if (!RegExp(r'^[A-Z0-9 -]*$').hasMatch(upper)) {
          return oldValue;
        }
        return newValue.copyWith(
          text: upper,
          selection: newValue.selection,
          composing: TextRange.empty,
        );
      });

  /// Phone keyboards occasionally emit spaces, brackets and a leading plus.
  static final TextInputFormatter phone = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9+() -]'),
  );
}
