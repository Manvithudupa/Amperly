import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/amp_colors.dart';
import '../../../../app/theme/amp_theme.dart';
import '../../../../core/formatting/amp_format.dart';
import '../../../../core/ui/strings.dart';
import '../../../../core/widgets/amp_icon.dart';
import '../../application/active_journey_provider.dart';

/// The quiet strip above the tab bar for the booking or session in hand.
class ActiveJourneyBanner extends StatelessWidget {
  const ActiveJourneyBanner({
    required this.journey,
    required this.onOpen,
    super.key,
  });

  final ActiveJourney journey;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final String line = switch (journey.kind) {
      ActiveJourneyKind.charging => AmpStrings.activeJourneyCharging(
        journey.stationName,
        AmpFormat.kWh(journey.energyKwh),
      ),
      ActiveJourneyKind.startingSoon => AmpStrings.activeJourneyStarting(
        journey.stationName,
        AmpFormat.clock(journey.startTimeMs),
      ),
    };

    return Semantics(
      button: true,
      label: line,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surfaceVariant,
          child: InkWell(
            onTap: onOpen,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AmpTheme.screenPadding,
                AmpTheme.spaceS,
                AmpTheme.screenPadding,
                AmpTheme.spaceS,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              child: Row(
                children: <Widget>[
                  AmpIcon(AmpIconName.bolt, size: 18, color: colors.energy),
                  const SizedBox(width: AmpTheme.spaceS),
                  Expanded(
                    child: Text(
                      line,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AmpTheme.spaceS),
                  Text(
                    AmpStrings.activeJourneyOpen,
                    style: TextStyle(
                      fontFamily: AmpTheme.uiFont,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  AmpIcon(
                    AmpIconName.chevronRight,
                    size: 16,
                    color: colors.primary,
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

class ConsumerActiveJourneyBanner extends ConsumerWidget {
  const ConsumerActiveJourneyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActiveJourney? journey = ref
        .watch(activeJourneyProvider)
        .asData
        ?.value;
    if (journey == null) {
      return const SizedBox.shrink();
    }
    return ActiveJourneyBanner(
      journey: journey,
      onOpen: () => context.push(journey.route),
    );
  }
}
