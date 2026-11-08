import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/auth_repository.dart';

/// Ends the shared phone/car session after one confirmation.
class SignOutButton extends ConsumerWidget {
  const SignOutButton({
    super.key,
    this.variant = AmpButtonVariant.tonal,
    this.label = AmpStrings.authSignOut,
  });

  final AmpButtonVariant variant;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AmpButton(
      label: label,
      variant: variant,
      onPressed: () async {
        final bool confirmed = await showAmpConfirmDialog(
          context,
          title: AmpStrings.authSignOutConfirmTitle,
          message: AmpStrings.authSignOutConfirmBody,
          confirmLabel: AmpStrings.authSignOut,
        );
        if (!confirmed || !context.mounted) {
          return;
        }

        final AuthRepository? repository = ref.read(authRepositoryProvider);
        if (repository == null) {
          AmpSnackbar.show(
            context,
            AmpStrings.authSignOutFailed,
            tone: AmpSnackbarTone.error,
          );
          return;
        }

        try {
          await repository.signOut();
        } on Object {
          if (context.mounted) {
            AmpSnackbar.show(
              context,
              AmpStrings.authSignOutFailed,
              tone: AmpSnackbarTone.error,
            );
          }
        }
      },
    );
  }
}
