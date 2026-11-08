import 'package:flutter/material.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_illustration.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../data/models/models.dart';
import 'sign_out_button.dart';

/// A blocked profile keeps the account session but loses the product surface.
class BlockedScreen extends StatelessWidget {
  const BlockedScreen({required this.profile, super.key});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (profile.name ?? '').trim();

    return AmpScaffold(
      title: AmpStrings.appName,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceL,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: <Widget>[
          const Center(
            child: AmpIllustration(
              AmpIllustrationKind.carQuestion,
              width: 176,
              height: 128,
            ),
          ),
          const SizedBox(height: AmpTheme.spaceL),
          const Center(
            child: AmpBadge(
              AmpStrings.blockedTitle,
              tone: AmpBadgeTone.danger,
              icon: AmpIconName.alert,
            ),
          ),
          const SizedBox(height: AmpTheme.spaceM),
          Text(
            AmpStrings.blockedTitle,
            textAlign: TextAlign.center,
            style: text.displaySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.blockedBody,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: colors.inkSecondary),
          ),
          const SizedBox(height: AmpTheme.spaceL),
          Container(
            padding: const EdgeInsets.all(AmpTheme.spaceM),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AmpStrings.authSignedInAs, style: text.labelLarge),
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? AmpStrings.appName : name,
                  style: text.titleMedium,
                ),
                if ((profile.email ?? '').trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(profile.email!, style: text.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: AmpTheme.spaceL),
          const SignOutButton(label: AmpStrings.blockedSignOut),
        ],
      ),
    );
  }
}
