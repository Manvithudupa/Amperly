import '../policy.dart';

final class EnforcementDecision {
  const EnforcementDecision({
    required this.action,
    required this.reason,
    required this.fineAmount,
    required this.suspendStation,
    required this.banStation,
    required this.freezePayout,
    required this.audienceSteps,
    required this.hostMessage,
  });

  final String action;
  final String reason;
  final double fineAmount;
  final bool suspendStation;
  final bool banStation;
  final bool freezePayout;
  final List<String> audienceSteps;
  final String hostMessage;
}

abstract final class EnforcementPolicyEngine {
  static const double defaultFineInr = AmpPolicy.enforcementFineInr;
  static const int dayMs = AmpPolicy.suspensionDayMs;

  static EnforcementDecision forUnverifiedAccusation() {
    return const EnforcementDecision(
      action: AmpPolicy.enforcementNone,
      reason: 'Accusation is not yet supported by evidence.',
      fineAmount: 0,
      suspendStation: false,
      banStation: false,
      freezePayout: false,
      audienceSteps: <String>[
        'Consumer evidence is reviewed before any action is taken.',
        'No penalty is applied on an unverified accusation alone.',
      ],
      hostMessage:
          'No action taken. The consumer was told what evidence is needed.',
    );
  }

  static EnforcementDecision decide(
    int provenIncidentsIncludingThis,
    bool evidenceSufficient,
    bool severeFraud,
  ) {
    final List<String> steps = _baseSteps();
    if (!evidenceSufficient) {
      steps.add(
        'Evidence is insufficient, so the payout is held while the host responds.',
      );
      return EnforcementDecision(
        action: AmpPolicy.enforcementNone,
        reason: 'Evidence does not yet support a penalty.',
        fineAmount: 0,
        suspendStation: false,
        banStation: false,
        freezePayout: true,
        audienceSteps: List<String>.unmodifiable(steps),
        hostMessage:
            'Please share your meter photographs and session notes so the '
            'dispute can be closed.',
      );
    }
    if (severeFraud) {
      steps.add(
        'Severe or fraudulent behaviour results in immediate suspension and a ban.',
      );
      return EnforcementDecision(
        action: AmpPolicy.enforcementBan,
        reason: 'Proven severe fraud.',
        fineAmount: 0,
        suspendStation: true,
        banStation: true,
        freezePayout: true,
        audienceSteps: List<String>.unmodifiable(steps),
        hostMessage:
            'Your station has been suspended immediately pending a full review.',
      );
    }
    if (provenIncidentsIncludingThis <= 1) {
      steps.add('First proven incident: warning and consumer correction.');
      return EnforcementDecision(
        action: AmpPolicy.enforcementWarning,
        reason: 'First proven incident.',
        fineAmount: 0,
        suspendStation: false,
        banStation: false,
        freezePayout: false,
        audienceSteps: List<String>.unmodifiable(steps),
        hostMessage:
            'This is a formal warning. The consumer has been refunded or corrected.',
      );
    }
    if (provenIncidentsIncludingThis == 2) {
      steps.add('Second proven incident: warning plus fine.');
      return EnforcementDecision(
        action: AmpPolicy.enforcementFine,
        reason: 'Second proven incident.',
        fineAmount: defaultFineInr,
        suspendStation: false,
        banStation: false,
        freezePayout: false,
        audienceSteps: List<String>.unmodifiable(steps),
        hostMessage:
            'A fine of ₹${defaultFineInr.toInt()} applies and the consumer has '
            'been refunded.',
      );
    }
    if (provenIncidentsIncludingThis == 3) {
      steps.add('Third proven incident: station suspension.');
      return EnforcementDecision(
        action: AmpPolicy.enforcementSuspension,
        reason: 'Third proven incident.',
        fineAmount: defaultFineInr,
        suspendStation: true,
        banStation: false,
        freezePayout: true,
        audienceSteps: List<String>.unmodifiable(steps),
        hostMessage:
            'Your station is suspended until the outstanding issues are resolved.',
      );
    }
    steps.add('Repeated proven incidents: station ban.');
    return EnforcementDecision(
      action: AmpPolicy.enforcementBan,
      reason: 'Repeated proven incidents.',
      fineAmount: defaultFineInr,
      suspendStation: true,
      banStation: true,
      freezePayout: true,
      audienceSteps: List<String>.unmodifiable(steps),
      hostMessage: 'Your station has been banned from the platform.',
    );
  }

  static int suggestedSuspensionDays(int provenIncidentsIncludingThis) {
    if (provenIncidentsIncludingThis <= 1) {
      return AmpPolicy.suspensionDays[0];
    }
    if (provenIncidentsIncludingThis == 2) {
      return AmpPolicy.suspensionDays[1];
    }
    return AmpPolicy.suspensionDays[2];
  }

  static List<String> _baseSteps() => <String>[
    'Consumer evidence is reviewed.',
    'The payment or host payout is held temporarily during the review.',
    'The host is given an opportunity to respond.',
    'If the host is responsible, the consumer receives a refund or correction.',
  ];
}
