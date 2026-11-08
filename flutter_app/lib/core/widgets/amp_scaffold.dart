import 'package:flutter/material.dart';

import '../../app/theme/amp_colors.dart';
import '../../app/theme/amp_theme.dart';
import '../ui/strings.dart';
import 'amp_icon.dart';

/// The page frame every screen shares.
///
/// A quiet app bar, a paper body, and an optional sticky bottom bar with a
/// hairline instead of a shadow. Wordmark mode is for the sign-in screen.
class AmpScaffold extends StatelessWidget {
  const AmpScaffold({
    required this.body,
    super.key,
    this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.leading,
    this.bottomBar,
    this.floatingActionButton,
    this.padded = false,
    this.wordmark = false,
    this.showBack = true,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool padded;
  final bool wordmark;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final bool hasHeader =
        wordmark || title != null || subtitle != null || actions.isNotEmpty;
    final bool canPop = showBack && Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: hasHeader
          ? AppBar(
              leading:
                  leading ??
                  (canPop
                      ? IconButton(
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).backButtonTooltip,
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Transform.scale(
                            scaleX: -1,
                            child: AmpIcon(
                              AmpIconName.arrowRight,
                              color: colors.ink,
                              size: 22,
                            ),
                          ),
                        )
                      : null),
              title: wordmark
                  ? Text(
                      AmpStrings.wordmark,
                      style: TextStyle(
                        fontFamily: AmpTheme.displayFont,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                        color: colors.primary,
                      ),
                    )
                  : title == null
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(title!),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
              actions: actions,
            )
          : null,
      body: SafeArea(
        top: !hasHeader,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padded ? AmpTheme.screenPadding : 0,
          ),
          child: body,
        ),
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(
                  AmpTheme.screenPadding,
                  AmpTheme.spaceS,
                  AmpTheme.screenPadding,
                  AmpTheme.spaceS,
                ),
                child: bottomBar!,
              ),
            ),
      floatingActionButton: floatingActionButton,
    );
  }
}
