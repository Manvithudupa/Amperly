import 'package:flutter/material.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
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
          const Eyebrow(AmpStrings.blockedTitle),
          const SizedBox(height: AmpTheme.spaceM),
          Text(AmpStrings.blockedTitle, style: text.displaySmall),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.blockedBody,
            style: text.bodyMedium?.copyWith(color: colors.inkSecondary),
          ),
          const SizedBox(height: AmpTheme.spaceL),
          const Hairline(),
          const SizedBox(height: AmpTheme.spaceM),
          const Eyebrow(AmpStrings.authSignedInAs),
          const SizedBox(height: 4),
          Text(
            name.isEmpty ? AmpStrings.appName : name,
            style: text.titleMedium,
          ),
          if ((profile.email ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(profile.email!.trim(), style: text.bodySmall),
          ],
          const SizedBox(height: AmpTheme.spaceM),
          const Hairline(),
          const SizedBox(height: AmpTheme.spaceS),
          const SignOutButton(label: AmpStrings.blockedSignOut),
        ],
      ),
    );
  }
}
