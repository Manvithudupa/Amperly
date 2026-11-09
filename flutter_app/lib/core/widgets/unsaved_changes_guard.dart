import 'package:flutter/material.dart';

import '../ui/strings.dart';
import 'confirm_dialog.dart';

/// Protects a form route from an accidental system back or swipe.
///
/// The route is allowed to pop normally when there is nothing to lose. When
/// there is input, the person gets the same discard sheet everywhere. The
/// caller decides where to go after the discard; a shell branch can switch to
/// Discover, while a pushed form can pop.
class AmpUnsavedChangesGuard extends StatefulWidget {
  const AmpUnsavedChangesGuard({
    required this.hasUnsavedChanges,
    required this.onDiscard,
    required this.child,
    super.key,
    this.title = AmpStrings.unsavedChangesTitle,
    this.message = AmpStrings.unsavedChangesBody,
    this.keepLabel = AmpStrings.unsavedKeepEditing,
    this.discardLabel = AmpStrings.unsavedDiscard,
  });

  final bool hasUnsavedChanges;
  final VoidCallback onDiscard;
  final Widget child;
  final String title;
  final String message;
  final String keepLabel;
  final String discardLabel;

  @override
  State<AmpUnsavedChangesGuard> createState() => _AmpUnsavedChangesGuardState();
}

class _AmpUnsavedChangesGuardState extends State<AmpUnsavedChangesGuard> {
  bool _allowPop = false;
  bool _confirming = false;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !widget.hasUnsavedChanges || _allowPop,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || _confirming) {
          return;
        }
        _confirmDiscard();
      },
      child: widget.child,
    );
  }

  Future<void> _confirmDiscard() async {
    _confirming = true;
    final bool discard = await showAmpConfirmDialog(
      context,
      title: widget.title,
      message: widget.message,
      confirmLabel: widget.discardLabel,
      cancelLabel: widget.keepLabel,
    );
    if (!mounted) {
      return;
    }
    _confirming = false;
    if (!discard) {
      return;
    }
    setState(() => _allowPop = true);
    widget.onDiscard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _allowPop = false);
      }
    });
  }
}
