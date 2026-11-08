import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';
import 'amp_button.dart';

/// A confirmation that arrives from the bottom of the screen, where the thumb
/// already is. Destructive actions get the danger weight and are never the
/// first button in reading order.
Future<bool> showAmpConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = AmpStrings.cancel,
  bool destructive = true,
}) async {
  final bool? result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext sheetContext) {
      final AmpColors c = sheetContext.amp;
      return Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        label: title,
        child: Material(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AmpTheme.radiusCard),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AmpTheme.screenPadding,
              AmpTheme.spaceS,
              AmpTheme.screenPadding,
              AmpTheme.spaceL + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const SizedBox(height: AmpTheme.spaceL),
                  Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AmpTheme.spaceS),
                  Text(
                    message,
                    style: Theme.of(
                      sheetContext,
                    ).textTheme.bodyMedium?.copyWith(color: c.inkSecondary),
                  ),
                  const SizedBox(height: AmpTheme.spaceL),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: AmpButton(
                          label: cancelLabel,
                          variant: AmpButtonVariant.quiet,
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                          expand: false,
                        ),
                      ),
                      const SizedBox(width: AmpTheme.spaceS),
                      Expanded(
                        child: AmpButton(
                          label: confirmLabel,
                          variant: destructive
                              ? AmpButtonVariant.danger
                              : AmpButtonVariant.primary,
                          onPressed: () => Navigator.of(sheetContext).pop(true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  return result ?? false;
}
