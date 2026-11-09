import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';
import 'amp_icon.dart';

/// A labelled, outlined field.
///
/// The label sits above the box, so the field can carry a helper line and an
/// inline error without the label jumping or the box growing a second border.
/// Validation messages arrive from the caller; they are already friendly copy,
/// never a parser or server string.
class AmpField extends StatefulWidget {
  const AmpField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.controller,
    this.initialValue,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscure = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.autofillHints,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.focusNode,
    this.prefixIcon,
    this.suffix,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : assert(
         controller == null || initialValue == null,
         'Use a controller or an initial value, not both.',
       );

  final String? label;
  final String? hint;
  final String? helper;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscure;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;
  final FocusNode? focusNode;
  final AmpIconName? prefixIcon;
  final Widget? suffix;
  final AutovalidateMode autovalidateMode;

  @override
  State<AmpField> createState() => _AmpFieldState();
}

class _AmpFieldState extends State<AmpField> {
  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  FocusNode? _internalFocus;
  bool _hadFocus = false;
  bool _revealed = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocus!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocus = FocusNode();
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(AmpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _internalFocus)?.removeListener(
        _handleFocusChange,
      );
      if (widget.focusNode == null) {
        _internalFocus ??= FocusNode();
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocus?.dispose();
    super.dispose();
  }

  /// A field validates when the keyboard moves away from it, not only when the
  /// form is submitted. The error stays inline under the same box.
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _hadFocus = true;
      return;
    }
    if (_hadFocus) {
      _fieldKey.currentState?.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final bool isObscured = widget.obscure && !_revealed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontFamily: AmpTheme.uiFont,
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                color: c.inkSecondary,
              ),
            ),
          ),
        TextFormField(
          key: _fieldKey,
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          obscureText: isObscured,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTapOutside:
              widget.onTapOutside ??
              (PointerDownEvent event) => FocusScope.of(context).unfocus(),
          scrollPadding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
          focusNode: _focusNode,
          autovalidateMode: widget.autovalidateMode,
          style: Theme.of(context).textTheme.bodyLarge,
          cursorColor: c.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            counterText: widget.maxLength == null ? null : '',
            helperText: widget.helper,
            helperMaxLines: 3,
            errorMaxLines: 3,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: AmpIcon(
                      widget.prefixIcon!,
                      size: 19,
                      color: c.inkSecondary,
                    ),
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: widget.obscure
                ? TextButton(
                    onPressed: () => setState(() => _revealed = !_revealed),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: c.primary,
                      textStyle: TextStyle(
                        fontFamily: AmpTheme.uiFont,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: c.primary,
                      ),
                    ),
                    child: Text(_revealed ? AmpStrings.hide : AmpStrings.show),
                  )
                : widget.suffix,
          ),
        ),
      ],
    );
  }
}
