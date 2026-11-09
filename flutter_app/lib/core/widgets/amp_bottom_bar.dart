import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

final class AmpBottomDestination {
  const AmpBottomDestination(this.label);

  final String label;
}

/// A label-only bottom bar.
///
/// Five words, always visible. The active item gets a 2px amber mark at the
/// top edge and ink text; there is no pill, no icon and no elevation.
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: <Widget>[
              for (int index = 0; index < destinations.length; index++)
                Expanded(
                  child: _BottomItem(
                    label: destinations[index].label,
                    selected: index == currentIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

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
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: selected ? 20 : 0,
                  height: 2,
                  color: colors.energy,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: AmpTheme.uiFont,
                          fontSize: 11.5,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                          color: selected ? colors.ink : colors.inkSecondary,
                        ),
                      ),
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
