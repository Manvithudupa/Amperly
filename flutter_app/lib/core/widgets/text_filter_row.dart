import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

final class TextFilterOption<T> {
  const TextFilterOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// Filters as words, not pills.
///
/// The selected word is ink with an amber 2px underline; the rest are
/// ink-secondary. A disabled option still shows its word, quieter, so the row
/// does not reflow when a vehicle is added.
class TextFilterRow<T> extends StatelessWidget {
  const TextFilterRow({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<TextFilterOption<T>> options;
  final T? selected;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (int index = 0; index < options.length; index++)
            Padding(
              padding: EdgeInsets.only(
                right: index == options.length - 1 ? 0 : 26,
              ),
              child: _FilterWord<T>(
                option: options[index],
                selected: options[index].value == selected,
                onSelected: onSelected,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterWord<T> extends StatelessWidget {
  const _FilterWord({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  final TextFilterOption<T> option;
  final bool selected;
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final bool enabled = option.enabled && onSelected != null;
    final Duration motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final Color color = selected
        ? colors.ink
        : enabled
        ? colors.inkSecondary
        : colors.inkSecondary.withValues(alpha: 0.38);

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      label: option.label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? () => onSelected!(option.value) : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedDefaultTextStyle(
                    duration: motion,
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontFamily: AmpTheme.uiFont,
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0,
                      color: color,
                    ),
                    child: Text(option.label),
                  ),
                  const SizedBox(height: 7),
                  AnimatedContainer(
                    duration: motion,
                    curve: Curves.easeOut,
                    height: 2,
                    color: selected ? colors.energy : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
