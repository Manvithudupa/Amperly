import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';

/// Opens an Amperly sheet with three snap points.
///
/// The sheet is springy but never bouncy: the drag physics do the work. The
/// child is placed in one scroll view so a tall form still reaches the keyboard
/// and a short one does not leave an empty gap.
Future<T?> showAmpSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  List<double> snapPoints = const <double>[0.45, 0.75, 0.92],
  bool isDismissible = true,
}) {
  assert(snapPoints.length == 3, 'A sheet gets exactly three snap points.');
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: true,
    useSafeArea: true,
    builder: (BuildContext sheetContext) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: snapPoints.first,
        minChildSize: snapPoints.first,
        maxChildSize: snapPoints.last,
        snap: true,
        snapSizes: snapPoints,
        builder: (BuildContext context, ScrollController scrollController) {
          return AmpSheet(
            scrollController: scrollController,
            title: title,
            child: builder(sheetContext),
          );
        },
      );
    },
  );
}

/// The sheet's surface. Prefer [showAmpSheet]; use this directly only when a
/// caller already owns the draggable scroll controller.
class AmpSheet extends StatelessWidget {
  const AmpSheet({
    required this.child,
    required this.scrollController,
    super.key,
    this.title,
  });

  final Widget child;
  final ScrollController scrollController;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final AmpColors c = context.amp;
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: c.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AmpTheme.radiusCard),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceS,
          AmpTheme.screenPadding,
          AmpTheme.spaceL + keyboard,
        ),
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (title != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceM),
            Semantics(
              header: true,
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
          const SizedBox(height: AmpTheme.spaceM),
          child,
        ],
      ),
    );
  }
}
