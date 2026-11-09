import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import 'amp_icon.dart';

final class AmpBottomDestination {
  const AmpBottomDestination({required this.label, required this.icon});

  final String label;
  final AmpIconName icon;
}

/// A compact icon-and-label bottom bar.
///
/// Every destination keeps its word visible. The active item gets a 2px amber
/// mark at the top edge, an ink icon and a heavier label; there is no pill and
/// no elevation.
class AmpBottomBar extends StatelessWidget {
  const AmpBottomBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
    super.key,
  });

  final List<AmpBottomDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: <Widget>[
                for (int index = 0; index < destinations.length; index++)
                  Expanded(
                    child: _BottomItem(
                      label: destinations[index].label,
                      icon: destinations[index].icon,
                      selected: index == currentIndex,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AmpIconName icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color foreground = selected ? colors.ink : colors.inkSecondary;
    final Duration motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 180);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                AnimatedContainer(
                  duration: motion,
                  curve: Curves.easeOut,
                  width: selected ? 24 : 0,
                  height: 2,
                  color: colors.energy,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AmpIcon(
                          icon,
                          size: 22,
                          color: foreground,
                          strokeWidth: selected ? 2 : 1.75,
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedDefaultTextStyle(
                            duration: motion,
                            curve: Curves.easeOut,
                            style: TextStyle(
                              fontFamily: AmpTheme.uiFont,
                              fontSize: 11.5,
                              height: 1.2,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              letterSpacing: 0,
                              color: foreground,
                            ),
                            child: Text(label, maxLines: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
