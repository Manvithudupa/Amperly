import 'package:flutter/material.dart';

import '../../../../app/theme/amp_theme.dart';
import '../../../../core/formatting/amp_format.dart';
import '../../../../core/ui/strings.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../core/widgets/hairline.dart';
import '../../../../core/widgets/text_action.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/journey_repository.dart';

/// The quiet hand-back to a plan saved before the app was closed.
class SavedTripCard extends StatelessWidget {
  const SavedTripCard({
    required this.journey,
    required this.onResume,
    super.key,
  });

  final SavedJourney journey;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final RoutePlan plan = journey.plan;
    final TextTheme text = Theme.of(context).textTheme;
    final String origin = _valueOr(plan.origin, AmpStrings.tripMapPin);
    final String destination = _valueOr(
      plan.destination,
      AmpStrings.tripSavedDestinationUnknown,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Eyebrow(AmpStrings.tripSavedTitle),
        const SizedBox(height: 6),
        Text(
          AmpStrings.tripSavedRoute(origin, destination),
          style: text.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          AmpStrings.tripSavedSummary(
            AmpFormat.km(plan.totalDistanceKm),
            AmpFormat.duration(Duration(minutes: plan.totalJourneyMinutes)),
            journey.chargingStopCount,
          ),
          style: text.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(AmpStrings.tripSavedHint, style: text.bodySmall),
        Align(
          alignment: Alignment.centerLeft,
          child: TextAction(AmpStrings.tripResumeAction, onPressed: onResume),
        ),
        const SizedBox(height: AmpTheme.spaceS),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceM),
      ],
    );
  }

  static String _valueOr(String? value, String fallback) {
    final String trimmed = (value ?? '').trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }
}
