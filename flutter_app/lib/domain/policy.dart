/// Values that come from the product contract, not from a screen.
///
/// The database stores codes; these constants are the only place the Dart app
/// repeats them. Money values are Indian rupees as the backend stores them.
abstract final class AmpPolicy {
  static const String roleConsumer = 'CONSUMER';
  static const String roleHost = 'HOST';
  static const String roleAdmin = 'ADMIN';

  static const String level1VerifiedManual = 'LEVEL_1';
  static const String level2SimulatedSmartMeter = 'LEVEL_2';
  static const String level3NoVerifiedMeter = 'LEVEL_3';

  static const String portAvailable = 'AVAILABLE';
  static const String portOccupied = 'OCCUPIED';
  static const String portMaintenance = 'MAINTENANCE';
  static const String portReserved = 'RESERVED';

  static const String statusReserved = 'RESERVED';
  static const String statusCheckedIn = 'CHECKED_IN';
  static const String statusCharging = 'CHARGING';
  static const String statusCompleted = 'COMPLETED';
  static const String statusCancelled = 'CANCELLED';
  static const String statusExpired = 'EXPIRED';
  static const String statusDisputed = 'DISPUTED';
  static const String statusRefunded = 'REFUNDED';

  static const String routePlanActive = 'ACTIVE';
  static const String routePlanSuperseded = 'SUPERSEDED';

  static const String approvalPending = 'PENDING';
  static const String approvalApproved = 'APPROVED';
  static const String approvalRejected = 'REJECTED';

  static const String enforcementNone = 'NONE';
  static const String enforcementWarning = 'WARNING';
  static const String enforcementFine = 'FINE';
  static const String enforcementSuspension = 'SUSPENSION';
  static const String enforcementBan = 'BAN';

  static const String paymentAuthorized = 'AUTHORIZED';
  static const String paymentCaptured = 'CAPTURED';
  static const String paymentFailed = 'FAILED';
  static const String paymentRefunded = 'REFUNDED';
  static const String paymentReleased = 'RELEASED';

  static const String invoiceIssued = 'ISSUED';
  static const String invoicePartiallyRefunded = 'PARTIALLY_REFUNDED';
  static const String invoiceRefunded = 'REFUNDED';
  static const String invoicePaid = 'PAID';

  static const double defaultServiceFeeInr = 5;
  static const double defaultGatewayFeeInr = 4;
  static const double fallbackTariffInrPerKwh = 18;
  static const double lateCancellationFeeInr = 20;
  static const double meterReadReviewThresholdKwh = 150;

  static const int defaultMinReserveSocPercent = 15;
  static const int defaultMaxTargetSocPercent = 80;
  static const int defaultChargeTargetSocPercent = 80;
  static const int minimumChargeSocGain = 10;

  static const double averageSpeedKmh = 45;
  static const double chargingEfficiencyFactor = 0.8;
  static const int minimumChargingMinutes = 10;
  static const int maxPlannedStops = 5;

  static const int maxHoldMinutes = 12 * 60;
  static const int freeCancellationMinutes = 60;

  static const String bookingPrefix = 'AMP-';
  static const String bookingAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const int bookingCodeLength = 6;

  static const int chatThreadLifetimeDays = 7;
  static const int searchDebounceMs = 300;
  static const int searchMinimumCharacters = 3;
  static const int searchSuggestionLimit = 5;

  static const int routingStartsPerSecond = 4;
  static const int routeCacheCapacity = 20;
  static const int routeCacheTtlMinutes = 10;

  static const double enforcementFineInr = 500;
  static const List<int> suspensionDays = <int>[1, 7, 30];
  static const int suspensionDayMs = 24 * 60 * 60 * 1000;

  static const String geocodingCountryFilter = 'countrycode:in';
  static const String mapAttribution =
      'Map data © OpenStreetMap contributors · Powered by Geoapify';
}
