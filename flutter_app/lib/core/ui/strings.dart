/// Every string a person can read lives here.
///
/// Widgets take labels as parameters or read from this class. A literal in a
/// widget is a bug: it is the one thing that makes copy impossible to audit.
abstract final class AmpStrings {
  // ------------------------------------------------------------- brand
  static const String appName = 'Amperly';
  static const String wordmark = 'Amperly';
  static const String openGalleryHint = 'Preview the component gallery.';

  // ------------------------------------------------------- configuration
  static const String configMissingTitle = 'This build has no settings.';
  static const String configMissingBody =
      'Copy env.json.example to env.json and fill in the Supabase project URL '
      'and publishable key, then start the app again.';
  static const String configSecretTitle = 'This build cannot start.';
  static const String configSecretBody =
      'The configured key is a server secret. Replace it with the publishable '
      'key; a secret key must never ship inside an app.';
  static const String configInvalidBody =
      'The settings in env.json could not be read. Check the file and start '
      'the app again.';
  static const String configBackendTitle = 'The server is not answering.';
  static const String configBackendBody =
      'Amperly could not open a connection to its backend. Check the settings '
      'and try again.';
  static const String configNotConfigured = 'Not configured';
  static const String configMissingNotice =
      'This build has no backend settings, so sign-in cannot work yet. Add '
      'the Supabase URL and publishable key to local.properties and rebuild.';

  // ---------------------------------------------------------- navigation
  static const String routeNotFoundTitle = 'Page not found';
  static const String routeNotFoundBody =
      'That link does not lead anywhere in Amperly.';

  // -------------------------------------------------------- common actions
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String retry = 'Try again';
  static const String close = 'Close';
  static const String undo = 'Undo';
  static const String delete = 'Delete';
  static const String dismiss = 'Dismiss';
  static const String show = 'Show';
  static const String hide = 'Hide';

  // ---------------------------------------------------------- freshness
  static const String updatedJustNow = 'Updated just now';
  static String updatedMinutes(int minutes) => 'Updated $minutes min ago';
  static String updatedHours(int hours) => 'Updated $hours h ago';
  static String updatedDays(int days) => 'Updated $days days ago';
  static const String stale = 'May be out of date';

  // --------------------------------------------------------------- units
  static const String perKwh = '/kWh';
  static const String kwh = 'kWh';
  static const String km = 'km';
  static const String percent = '%';

  // --------------------------------------------------------------- errors
  static const String errorOffline =
      'You are offline. Check your connection and try again.';
  static const String errorTimeout =
      'That took too long. Check your connection and try again.';
  static const String errorSessionExpired =
      'Your session has ended. Sign in again to continue.';
  static const String errorPermission =
      'You do not have access to that. If it is your account, sign in again.';
  static const String errorNotFound =
      'We could not find that. It may have been removed.';
  static const String errorConflict =
      'That changed while you were looking. Refresh and try again.';
  static const String errorSlotTaken =
      'Someone booked that slot first. Pick another time.';
  static const String errorValidation =
      'Some details need fixing. Check the highlighted fields.';
  static const String errorRateLimited =
      'Too many requests just now. Wait a moment and try again.';
  static const String errorServer =
      'Something went wrong on our side. Try again in a moment.';
  static const String errorMapUnavailable =
      'The map is not responding. You can still see your bookings.';
  static const String errorNoResults =
      'No matches. Try a different place or spelling.';
  static const String errorUnknown = 'That did not go through. Try again.';

  // ---------------------------------------------------------------- auth
  static const String authTitle = 'Welcome back.';
  static const String authBody =
      'Sign in with the email and password for your Amperly account.';
  static const String authCreateTitle = 'Create your account.';
  static const String authCreateBody =
      'One account books charging and lists your own charger.';
  static const String authName = 'Full name';
  static const String authNameHint = 'As it should appear on a booking';
  static const String authEmail = 'Email';
  static const String authEmailHint = 'you@example.com';
  static const String authPassword = 'Password';
  static const String authPasswordHint = 'At least 6 characters';
  static const String authSignIn = 'Sign in';
  static const String authCreating = 'Creating account';
  static const String authSigningIn = 'Signing in';
  static const String authCreateAccount = 'Create account';
  static const String authHaveAccount = 'I already have an account';
  static const String authCreatePrompt = 'New to Amperly? Create an account';
  static const String authNameRequired = 'Enter your name.';
  static const String authEmailRequired = 'Enter your email address.';
  static const String authEmailInvalid = 'Enter a valid email address.';
  static const String authPasswordTooShort = 'Use at least 6 characters.';
  static String authConfirmEmail(String email) =>
      'Account created. Confirm the email sent to $email, then sign in.';
  static const String authInvalidCredentials =
      'That email or password does not match. Try again.';
  static const String authEmailUnconfirmed =
      'Confirm your email first. We sent you a link.';
  static const String authAlreadyRegistered =
      'An account with that email already exists. Sign in instead.';
  static const String authSignedIn = 'Signed in';
  static const String authSignedInTitle = 'Your account is ready.';
  static const String authSignedInBody =
      'The phone and Android Auto now share one secure session. Charger '
      'discovery, trip planning, your garage and account stay in step on both '
      'surfaces.';
  static const String authSignedInAs = 'Signed in as';
  static const String authSessionShared =
      'Android Auto reads this same account session. Signing out here clears '
      'the account on both surfaces.';
  static const String authSignOut = 'Sign out';
  static const String authSignOutConfirmTitle = 'Sign out of Amperly?';
  static const String authSignOutConfirmBody =
      'This ends the session on the phone and in the car, and clears this '
      'device’s cached account data.';
  static const String authSignOutFailed =
      'Sign out could not finish. Check your connection and try again.';

  // ------------------------------------------------------------- discovery
  static const String discoverTitle = 'Discover';
  static const String discoverSubtitle =
      'Approved chargers from the live catalogue.';
  static String discoverVehicleLine(String vehicle, String connector) =>
      'Planning for $vehicle · $connector';
  static const String discoverNoVehicle =
      'No vehicle saved — showing every connector.';
  static String discoverCount(int count) =>
      count == 1 ? '1 charger' : '$count chargers';
  static const String unnamedCharger = 'Unnamed charger';
  static const String addressNotPublished = 'Address not published';
  static const String connectorNotPublished = 'Connector not published';
  static const String powerNotPublished = 'Power not published';
  static const String priceNotPublished = 'Price not published';
  static const String discoverEmptyTitle = 'No chargers published yet';
  static const String discoverEmptyBody =
      'When a host publishes a charger and an admin approves it, it appears '
      'here.';
  static const String discoverNoMatchesBody =
      'Clear the filter to see every approved charger.';
  static const String discoverShowAll = 'Show all chargers';
  static const String filterAll = 'All';
  static const String filterCompatible = 'Compatible';
  static const String filterDc = 'DC fast';
  static const String filterMeter = 'Verified meter';
  static const String filterNeedsVehicle =
      'A saved vehicle is needed for this filter.';
  static const String availabilityUnknown = 'Availability age not published';
  static const String portsNotPublished = 'No ports published';
  static const String noPortsAvailable = 'No port available now';
  static String portsAvailable(int available, int total) =>
      '$available of $total ports available now';

  // -------------------------------------------------------- charger details
  static const String detailsTitle = 'Charger';
  static const String detailsAvailability = 'Availability now';
  static const String detailsAvailabilityNote =
      'Port status is reported by the host, not live charger hardware.';
  static const String detailsOperatingHours = 'Published hours';
  static const String detailsReliabilityUnknown =
      'Reliability and rating have not been published.';
  static const String labelUnknown = 'Unknown';
  static const String detailsPorts = 'Ports';
  static const String detailsPrice = 'Price per kWh';
  static const String detailsEnergyPrice = 'Energy';
  static const String detailsServiceFee = 'Service fee';
  static const String detailsGatewayFee = 'Gateway fee';
  static const String detailsTotal = 'Total per kWh';
  static const String detailsBillingNote =
      'The final bill is based on verified meter readings. Fees are fixed '
      'platform amounts and are shown before booking.';
  static const String detailsMeterGating =
      'Discovery only. This station has no verified meter, so Amperly cannot '
      'bill an energy session automatically.';
  static const String detailsAccess = 'Access';
  static const String detailsNoAccess = 'Access rules were not published.';
  static const String detailsHost = 'Host and reliability';
  static const String detailsNoHost = 'Host not published';
  static const String detailsNoPorts =
      'No ports have been published for this charger.';
  static const String detailsPortStatus = 'Status';
  static String detailsReliability(int score, String rating, int incidents) =>
      'Reliability $score/100 · Rating $rating · $incidents reported '
      'incident${incidents == 1 ? '' : 's'}';

  // ---------------------------------------------------------------- account
  static const String accountTitle = 'Profile';
  static const String accountRole = 'Account type';
  static const String accountVerification = 'Verification';
  static const String accountVehicleTitle = 'Vehicle in use';
  static const String accountNoVehicle = 'No vehicle saved yet.';
  static const String accountNoVehicleBody =
      'Compatibility filtering stays off until a vehicle is saved to this '
      'account.';
  static const String accountConsumer = 'Consumer';
  static const String accountHost = 'Host';
  static const String accountAdmin = 'Administrator';
  static const String accountPending = 'Pending';
  static const String accountUnverified = 'Unverified';

  // ---------------------------------------------------------------- vehicles
  static const String vehicleGarageTitle = 'My vehicles';
  static const String vehicleGarageSubtitle =
      'The car in use sets range, connector checks and reservations.';
  static const String vehicleGarageIntro =
      'Every car you save here can be used for planning. The one marked in use '
      'is what range, charging and reservation checks use.';
  static const String vehicleAdd = 'Add a car';
  static const String vehicleAddTitle = 'Add a car';
  static const String vehicleEditTitle = 'Edit vehicle';
  static const String vehicleFormIntro =
      'Used for range and charging plans only. These figures are never '
      'presented as a certified battery measurement.';
  static const String vehicleSectionIdentity = 'Vehicle';
  static const String vehicleSectionBattery = 'Battery and charging';
  static const String vehicleSectionPreferences = 'Preferences';
  static const String vehicleMake = 'Company';
  static const String vehicleModel = 'Model';
  static const String vehicleVariant = 'Variant';
  static const String vehicleYear = 'Year of purchase';
  static const String vehicleCapacity = 'Battery capacity (kWh)';
  static const String vehicleConnector = 'Connector';
  static const String vehicleMaxAc = 'Max AC charging (kW)';
  static const String vehicleMaxDc = 'Max DC charging (kW)';
  static const String vehicleEfficiency = 'Efficiency (km/kWh)';
  static const String vehicleHealth = 'Battery health (%)';
  static const String vehicleMinArrival = 'Minimum arrival battery (%)';
  static const String vehicleMaxCharge = 'Target maximum charge (%)';
  static const String vehiclePlate = 'Vehicle registration';
  static const String vehicleEmptyTitle = 'No vehicles yet';
  static const String vehicleEmptyBody =
      'Add your car to get range estimates, connector matching and '
      'reservations.';
  static const String vehicleActiveBadge = 'In use';
  static const String vehicleUseThis = 'Use this car';
  static const String vehicleNoRegistration = 'No registration';
  static const String vehicleSave = 'Save vehicle';
  static const String vehicleSaving = 'Saving';
  static const String vehicleSaved = 'Vehicle saved.';
  static const String vehicleSaveFailed =
      'Could not save your vehicle. Please try again.';
  static const String vehicleSwitchFailed =
      'Could not switch vehicle. Please try again.';
  static String vehicleSwitched(String name) => 'Planning for $name now.';
  static const String vehicleDelete = 'Delete this vehicle';
  static String vehicleDeleteTitle(String name) => 'Delete $name?';
  static const String vehicleDeleteBody =
      'It will be removed from your garage. Reservations and receipts already '
      'made are not affected.';
  static const String vehicleDeleted = 'Vehicle removed.';
  static const String vehicleDeleteFailed =
      'Could not remove this vehicle. Please try again.';
  static const String vehicleNotFoundTitle = 'Vehicle not found';
  static const String vehicleNotFoundBody =
      'That vehicle is no longer in your garage.';
  static const String vehicleManage = 'Manage vehicles';
  static const String vehicleMakeRequired = 'Enter the company and model.';
  static const String vehicleModelRequired = 'Enter the model.';
  static const String vehicleYearInvalid =
      'Enter a year between 1980 and next year.';
  static const String vehicleCapacityInvalid =
      'Enter a battery capacity between 1 and 200 kWh.';
  static const String vehicleMaxAcInvalid =
      'Enter an AC limit between 0 and 50 kW.';
  static const String vehicleMaxDcInvalid =
      'Enter a DC limit between 0 and 500 kW.';
  static const String vehicleEfficiencyInvalid =
      'Enter efficiency between 1 and 20 km/kWh.';
  static const String vehicleHealthInvalid =
      'Enter battery health between 1 and 100%.';
  static const String vehicleMinArrivalInvalid =
      'Enter an arrival reserve between 5 and 40%.';
  static const String vehicleMaxChargeInvalid =
      'Enter a target between 50 and 100%.';
  static const String vehicleSocOrder =
      'The target charge must be higher than the arrival reserve.';
  static String vehiclePlanningPreview(double usableKwh, int rangeKm) =>
      'Planning with ${usableKwh.toStringAsFixed(1)} kWh usable · about '
      '$rangeKm km of range.';
  static const String vehiclePlanningNote =
      'This is a planning estimate from your figures, not a certified battery '
      'measurement.';
  static String vehicleCardStats(
    double capacityKwh,
    double efficiency,
    int rangeKm,
  ) =>
      '${capacityKwh.toStringAsFixed(1)} kWh usable · '
      '${efficiency.toStringAsFixed(1)} km/kWh · about $rangeKm km';
  static String vehicleCardMeta(String plate, String connector) =>
      '$plate · $connector';

  // ------------------------------------------------------------------- trips
  static const String tripsTitle = 'Plan a trip';
  static const String tripsSubtitle =
      'A real road route, the car in use, and charging stops that keep a '
      'reserve.';
  static const String tripStartSection = 'Starting point';
  static const String tripDestinationSection = 'Destination';
  static const String tripBatterySection = 'Battery';
  static const String tripLocating = 'Finding your current location…';
  static const String tripCurrentLocation = 'Your current location';
  static const String tripMapPin = 'Starting point on the map';
  static const String tripAddressLookup = 'Looking up the address…';
  static const String tripGpsOnly = 'GPS position · address unavailable';
  static const String tripLocationPermission =
      'Location permission is off. Tap the map to set a starting point.';
  static const String tripLocationServices =
      'Location services are off. Tap the map to set a starting point.';
  static const String tripLocationUnavailable =
      'Current location is unavailable. Tap the map to set a starting point.';
  static const String tripUseLocation = 'Use my location';
  static const String tripMapHint = 'Tap the map to set the starting point.';
  static const String tripMapNeedsLocation =
      'Use your location or tap the map to set a starting point.';
  static const String tripDestinationHint =
      'Search a town, shop, hotel or landmark';
  static const String tripSearching = 'Searching places…';
  static String tripDestinationResolved(String address) =>
      'Destination: $address';
  static const String tripDestinationRequired = 'Choose a destination.';
  static const String tripMapSetupTitle = 'Map is not configured';
  static const String tripMapSetupBody =
      'This build has no Geoapify key, so place search, routing and map tiles '
      'are unavailable. Add the key to local.properties and rebuild.';
  static const String tripBatteryLabel = 'Current battery (%)';
  static const String tripBatteryHelper =
      'Take the reading from the dashboard; Amperly does not estimate it.';
  static const String tripBatteryInvalid =
      'Enter a battery reading between 0 and 100.';
  static const String tripBatteryRequired =
      'Set your current battery before planning.';
  static const String tripVehiclePlanningFor = 'Planning for';
  static const String tripNoVehicle =
      'No vehicle saved. Amperly will plan with default range figures.';
  static const String tripManageVehicles = 'Manage vehicles';
  static String tripVehicleChanged(String planned, String current) =>
      'This plan was made for $planned. The car in use is now $current; plan '
      'again to apply it.';
  static const String tripPreferencesTitle = 'How to choose stops';
  static const String tripCorridorLabel = 'Charger search radius';
  static String tripCorridorOption(int km) => '$km km';
  static const String tripPreferenceLabel = 'Prefer';
  static const String tripPrefFastest = 'Fastest';
  static const String tripPrefCheapest = 'Cheapest';
  static const String tripPrefReliable = 'Most reliable';
  static const String tripPrefShortest = 'Shortest detour';
  static const String tripPlanAction = 'Plan route and charging stops';
  static const String tripPlanning = 'Planning route…';
  static const String tripNeedsOrigin =
      'Set a starting point first. Use your location or tap the map.';
  static const String tripNeedsDestination = 'Enter a destination first.';
  static const String tripRouteFailed =
      'We couldn’t plan a route to that destination. Check it and try again.';
  static const String tripSearchFailed =
      'Place search is unavailable right now. Please try again.';
  static const String tripPlanFailed =
      'The route plan did not finish. Try again.';
  static const String tripTotalJourney = 'Total journey';
  static const String tripRouteProvider = 'Geoapify';
  static const String tripLoadingVehicle = 'Loading your vehicle…';
  static String tripDepartSoc(int soc) => 'Depart $soc%';
  static String tripArrivalReserve(int soc) => 'Arrival reserve $soc%';
  static String tripSummary(
    String distance,
    String drive,
    String charging,
    String total,
  ) => '$distance · $drive drive · $charging charging · $total total';
  static String tripConfidenceLabel(String confidence) {
    return switch (confidence.trim().toUpperCase()) {
      'HIGH' => 'High confidence',
      'MEDIUM' => 'Medium confidence',
      'LOW' => 'Low confidence',
      _ => 'Planning confidence',
    };
  }

  static String tripConfidenceLine(
    String label,
    int corridorKm,
    int candidates,
    int excluded,
  ) =>
      '$label · $corridorKm km corridor · $candidates candidate'
      '${candidates == 1 ? '' : 's'} · $excluded excluded';
  static String tripNoStopNeeded(int soc) =>
      'You can reach the destination with $soc% battery left, so no charging '
      'stop is needed.';
  static const String tripStopsTitle = 'Charging stops';
  static const String tripNoSafeTitle = 'No safe charging stop';
  static String tripNoSafeBody(int corridorKm) =>
      'No compatible charger inside the $corridorKm km corridor can be reached '
      'while keeping your arrival reserve.';
  static const String tripWiderSearch = 'Search a wider corridor';
  static String tripStopDetail(
    String along,
    String detour,
    int detourMin,
    int chargeMin,
  ) => '$along along · +$detour / +$detourMin min · $chargeMin min charge';
  static String tripStopSoc(int arrival, int departure) =>
      'Arrive $arrival% · charge to $departure%';
  static const String tripViewCharger = 'View charger';
  static const String tripBackupsTitle = 'Backup chargers';
  static const String tripDirectionsTitle = 'Directions';
  static String tripDirectionsMeta(
    String provider,
    String distance,
    String time,
  ) => '$provider · $distance · $time drive (no live traffic)';
  static const String tripDirectionsNote =
      'Directions from Geoapify, on OpenStreetMap data. Stops and battery '
      'figures are estimates.';
  static String tripMoreSteps(int count) =>
      '$count more step${count == 1 ? '' : 's'} not shown.';
  static const String tripAssumptionsTitle = 'Plan assumptions';
  static const String tripExcludedTitle = 'Not in this plan';
  static const String tripEstimateNotice =
      'Estimates only — final billing uses meter readings.';
  static const String tripNoBackups =
      'No other compatible charger was found near this route.';
  static const String tripDefaultVehicle = 'Default range figures';
  static const String tripRecommendedStop = 'Recommended stop';
  static const String tripNoChargingStops =
      'No charging stop is part of this plan.';

  // --------------------------------------------------------------- sessions
  static const String sessionHistoryTitle = 'Charging history';
  static const String sessionHistorySubtitle =
      'Settled sessions and their receipts.';
  static const String sessionHistoryEmptyTitle = 'No charging sessions yet';
  static const String sessionHistoryEmptyBody =
      'Open a booking, check in, and settle the meter reading. The receipt '
      'appears here.';
  static const String sessionOpenAction = 'Start charging session';
  static const String sessionContinueAction = 'Open charging session';
  static const String sessionViewReceipt = 'View receipt';
  static const String sessionTitle = 'Charging session';
  static const String sessionSubtitle = 'Meter-first check-in and settlement.';
  static const String sessionCheckInTitle = 'Check in at the charger';
  static const String sessionCheckInBody =
      'Read the starting value on the station meter. The server opens a '
      'session; no energy is charged until you settle the ending reading.';
  static const String sessionStartReadingLabel = 'Starting meter reading (kWh)';
  static const String sessionStartReadingHelper =
      'Use the value shown on the station meter now.';
  static const String sessionStartReadingRequired =
      'Enter the station meter reading to check in.';
  static const String sessionStartReadingInvalid =
      'Enter a starting reading of 0 or more.';
  static const String sessionCheckInAction = 'Check in';
  static const String sessionCheckingIn = 'Checking in…';
  static const String sessionCheckedInTitle = 'Checked in';
  static const String sessionCheckedInBody =
      'The server session is open. Connect the car, then start charging when '
      'energy begins flowing.';
  static const String sessionStartChargingAction = 'Start charging';
  static const String sessionStarting = 'Starting…';
  static const String sessionChargingTitle = 'Charging in progress';
  static const String sessionChargingBody =
      'Read the station meter when charging stops. The server recomputes the '
      'bill from both readings.';
  static const String sessionEndReadingLabel = 'Ending meter reading (kWh)';
  static const String sessionEndReadingHelper =
      'Use the value shown on the station meter when charging stops.';
  static const String sessionEndReadingRequired =
      'Enter the ending meter reading to settle.';
  static const String sessionEndReadingInvalid =
      'Enter an ending reading of 0 or more.';
  static const String sessionEndReadingBelowStart =
      'The ending reading cannot be lower than the starting reading.';
  static const String sessionFinishAction = 'Stop charging and see the bill';
  static const String sessionFinishing = 'Settling…';
  static const String sessionStartedLabel = 'Session started';
  static const String sessionElapsedLabel = 'Elapsed';
  static const String sessionNoSessionTitle = 'Session not open';
  static const String sessionNoSessionBody =
      'This booking is not active. Open a current booking to check in.';
  static const String sessionNoMeter =
      'This station has no verified meter, so a session cannot be settled.';
  static const String sessionNoPayment =
      'No payment is collected in this build. The invoice is issued, not '
      'charged.';
  static const String sessionInvoicePaid = 'Paid';
  static const String sessionInvoiceRefunded = 'Refunded';
  static const String sessionNoLongerSettle =
      'This booking can no longer be settled. Check its status.';
  static const String sessionMismatch =
      'This session does not match the booking. Reload before settling.';
  static const String sessionEvidenceMismatch =
      'These readings do not match the meter evidence recorded by the host. '
      'Ask the host to check the reading.';
  static const String sessionServerRequired =
      'Connect to the server to open or settle a session. Nothing was changed.';
  static const String sessionOpenFailed =
      'The session could not be opened. Nothing was billed.';
  static const String sessionStartFailed =
      'The session could not be marked as charging. Try again.';
  static const String sessionFinishFailed =
      'The server could not settle this session. No receipt was issued.';
  static const String sessionStatusWarning =
      'The session opened, but the booking status could not be updated. You '
      'can still charge and settle it.';
  static String sessionCheckedInToast(String kwh) =>
      'Checked in. Meter at $kwh.';
  static const String sessionChargingStarted = 'Charging started.';
  static const String sessionSettled = 'Session settled. Receipt issued.';
  static const String sessionReadingHint =
      'Readings are entered by hand from the station meter; the server '
      'recalculates the bill.';
  static const String sessionReadingNote =
      'The server recomputes these lines from the two readings when the '
      'session is settled.';
  static const String sessionMeterNote =
      'Readings were entered by hand from the station meter, not read from '
      'live charger hardware.';
  static const String sessionStationLabel = 'Charger';
  static const String sessionPortLabel = 'Port';
  static const String sessionSlotLabel = 'Slot';
  static const String sessionCodeLabel = 'Booking code';
  static const String sessionReadingsPending = 'Meter readings pending';
  static const String sessionReceiptTitle = 'Receipt';
  static const String sessionStationMissing =
      'This booking has no station to open a session against.';

  // ------------------------------------------------------------------ chat
  static const String chatTitle = 'Messages';
  static const String chatSubtitle =
      'Chat with the host about your charging slot. Phone numbers stay masked.';
  static const String chatInboxAction = 'Messages';
  static const String chatEmptyTitle = 'No conversations yet';
  static const String chatEmptyBody =
      'Open a booking in Your bookings and choose Message host. The '
      'conversation stays with that host for future visits.';
  static const String chatOpenBookings = 'View my bookings';
  static const String chatMessageHost = 'Message host';
  static const String chatOpeningFailed =
      'The conversation could not be opened. Check your connection and try '
      'again.';
  static const String chatNoHost =
      'This charger has no host account to message.';
  static const String chatNotFoundTitle = 'Conversation not found';
  static const String chatNotFoundBody =
      'That conversation is not on this account.';
  static const String chatNoMessagesTitle = 'No messages yet';
  static const String chatNoMessagesBody =
      'Ask the host about access, the port, or the meter reading.';
  static const String chatComposerHint = 'Write a message';
  static const String chatSend = 'Send';
  static const String chatMessageRequired = 'Write a message first.';
  static String chatMessageTooLong(int max) =>
      'Keep the message under $max characters.';
  static const String chatBlocked =
      'This conversation is blocked. You cannot send messages.';
  static const String chatDisabled = 'The host has closed this conversation.';
  static const String chatExpired =
      'This conversation has expired. Book with this host again to reopen it.';
  static const String chatSendFailed =
      'Your message was not sent. It is still in the box; try again.';
  static const String chatMaskedNote =
      'Phone numbers are masked. Off-platform payment requests are flagged.';
  static const String chatOffPlatformWarning =
      'Off-platform payment requests are flagged. Paying outside the app '
      'removes your dispute protection.';
  static String chatClosesOn(String date) => 'Chat closes on $date.';
  static const String chatHostFallback = 'Host';
  static String chatAboutStation(String station) => 'About $station';
  static const String chatNoMessagesPreview = 'No messages yet.';
  static const String chatQuickQuestionsTitle = 'Common questions';
  static const String chatClosedBadge = 'Closed';

  // --------------------------------------------------------------- bookings
  static const String bookingListTitle = 'Your bookings';
  static const String bookingListSubtitle =
      'Server-confirmed holds. No payment is collected in this build.';
  static const String bookingEmptyTitle = 'No bookings yet';
  static const String bookingEmptyBody =
      'Reserve a port at a charger and the confirmed slot appears here.';
  static const String bookingFindCharger = 'Find a charger';
  static const String bookingNoPayment =
      'No payment is collected in this build.';
  static const String bookingStationFallback = 'Charger';
  static const String bookingShowCode = 'Show code';
  static const String bookingViewCharger = 'View charger';
  static const String bookingCancelAction = 'Cancel booking';
  static const String bookingKeep = 'Keep booking';
  static const String bookingCancelTitle = 'Cancel this booking?';
  static const String bookingCancelFreeBody =
      'The slot is released immediately. No cancellation fee applies.';
  static String bookingCancelFeeBody(String fee) =>
      'The slot is released immediately, and a late cancellation fee of $fee '
      'is recorded. No payment is collected in this build.';
  static const String bookingCancelled = 'Booking cancelled.';
  static const String bookingCancelFailed =
      'The booking could not be cancelled. The server still shows it active.';
  static const String bookingTitle = 'Reserve a port';
  static const String bookingSubtitle =
      'The server confirms the slot; Amperly never holds it locally.';
  static const String bookingPortLabel = 'Port';
  static const String bookingDayLabel = 'Day';
  static const String bookingSlotLabel = 'Time slot';
  static const String bookingNoPorts =
      'No port is published as available right now.';
  static const String bookingNoCompatiblePorts =
      'No available port matches your vehicle connector.';
  static const String bookingNoSlots =
      'No free slots for this port on this day.';
  static const String bookingNoSchedules =
      'This port has not published opening hours, so slots cannot be shown.';
  static const String bookingVehicleLabel = 'Booking for';
  static const String bookingNoVehicle =
      'No vehicle saved. Connector checks stay open.';
  static const String bookingPriceTitle = 'Estimated price';
  static const String bookingEnergyEstimate = 'Estimated energy';
  static const String bookingEnergyCharge = 'Energy charge';
  static String bookingEnergyChargeValue(String amount, String tariff) =>
      '$amount at $tariff/kWh';
  static const String bookingServiceFee = 'Amperly service fee';
  static const String bookingGatewayFee = 'Gateway charge';
  static const String bookingTotal = 'Estimated total';
  static const String bookingPriceNote =
      'Every line is disclosed up front. No payment is collected in this build.';
  static const String bookingPolicyTitle = 'Cancellation policy';
  static const String bookingReserveAction = 'Reserve this slot';
  static const String bookingReserving = 'Reserving…';
  static const String bookingSuccessTitle = 'Booking confirmed';
  static const String bookingCodeTitle = 'Booking code';
  static const String bookingCodeLabel = 'Booking code';
  static const String bookingCodeHint = 'Show this code at the station.';
  static const String bookingQrHint =
      'If the scanner cannot read the code, use the letters below.';
  static const String bookingViewBookings = 'View my bookings';
  static const String bookingNotFoundTitle = 'Booking not found';
  static const String bookingNotFoundBody =
      'That booking is no longer on this account.';
  static const String bookingFreeCancellation =
      'Free cancellation is still available.';
  static const String bookingLateCancellation =
      'The late cancellation window has started; ₹20 is recorded if you '
      'cancel.';
  static const String bookingStationDetail = 'Charger';
  static const String bookingPortDetail = 'Port';
  static const String bookingTimeDetail = 'Slot';
  static const String bookingTariffDetail = 'Tariff';
  static const String bookingServiceDetail = 'Service fee';
  static const String bookingGatewayDetail = 'Gateway fee';
  static const String bookingSlotTaken =
      'That slot was just taken by someone else. Choose another time.';
  static const String bookingSlotPast =
      'That slot has already passed. Choose a later time.';
  static const String bookingSlotTooLong =
      'A booking can hold a port for at most 12 hours.';
  static const String bookingStationUnavailable =
      'This charger is no longer available for booking.';
  static const String bookingPortUnavailable =
      'That port is no longer available. Choose another port.';
  static const String bookingServerRequired =
      'Connect to the server to reserve or cancel. Nothing was changed.';
  static const String bookingToday = 'Today';
  static const String bookingTomorrow = 'Tomorrow';
  static String bookingTariffLine(
    String tariff,
    String service,
    String gateway,
  ) => '$tariff/kWh · $service service · $gateway gateway';

  static const String blockedTitle = 'Your account is restricted.';
  static const String blockedBody =
      'Booking, listing and account changes are paused. If you believe this '
      'is a mistake, contact the Amperly team.';
  static const String blockedSignOut = 'Sign out';
  static const String profileAction = 'Profile';

  // ---------------------------------------------------------------- states
  static const String offlineBannerText =
      'You are offline. Booking and changes need a connection.';
  static const String emptyTitle = 'Nothing here yet';
  static const String emptyBody =
      'When there is something to show, it appears here.';
  static const String errorTitle = 'That did not load';
  static const String noResultsTitle = 'No matches';
  static const String noResultsBody = 'Try a different place or spelling.';
  static const String noReachableTitle = 'No safe stop on this trip';
  static const String noReachableBody =
      'With the battery you entered, there is no charger we can reach with a '
      'reserve left. Try a shorter trip or a lower arrival reserve.';

  // ------------------------------------------------------------ components
  static const String batteryRingSemantics = 'Battery level. Tap to update.';
  static String batteryEstimateSemantics(int actual, int estimated) =>
      'You said $actual percent. The estimate was $estimated percent.';
  static const String meterMetered = 'Metered';
  static const String meterDiscoveryOnly = 'Discovery only';
  static const String verified = 'Verified';
  static const String pending = 'Pending';
  static const String receiptIssued = 'Issued';
  static const String notPaidNotice =
      'Invoices are issued, not charged. No payment is collected in this build.';
  static const String demoMeter = 'Demo meter';

  // --------------------------------------------------------------- gallery
  static const String galleryTitle = 'Component gallery';
  static const String galleryIntro =
      'The parts every screen is built from, shown in light and dark.';
  static const String galleryButtons = 'Buttons';
  static const String galleryBadges = 'Badges and chips';
  static const String galleryFields = 'Fields';
  static const String galleryBattery = 'Battery ring';
  static const String galleryConnectors = 'Connectors';
  static const String galleryPrice = 'Prices and figures';
  static const String galleryFreshness = 'Freshness';
  static const String galleryTimeline = 'Journey timeline';
  static const String galleryTicket = 'Ticket';
  static const String galleryReceipt = 'Receipt';
  static const String galleryStates = 'Empty, loading and error';
  static const String gallerySheets = 'Sheets and dialogs';
  static const String galleryFeedback = 'Feedback';
  static const String galleryPreviewLight = 'Light';
  static const String galleryPreviewDark = 'Dark';
  static const String galleryPreviewBoth = 'Both';
  static const String galleryPreviewMode = 'Preview';
  static const String gallerySamplePrice = '₹18';
  static const String gallerySampleStation = 'Indiranagar Community Charger';
  static const String gallerySamplePort = 'Port A · CCS2 · 60 kW';
  static const String gallerySampleCode = 'AMP-7K4Q2M';
  static const String gallerySampleSlot = 'Today, 6:30 pm – 7:15 pm';
  static const String galleryConfirmTitle = 'Cancel this booking?';
  static const String galleryConfirmBody =
      'The slot is released for someone else. Cancelling within 60 minutes of '
      'the start carries a ₹20 fee.';
  static const String galleryConfirmAction = 'Cancel booking';
  static const String gallerySheetTitle = 'Reserve a port';
  static const String gallerySheetBody =
      'Pick a port and a time. The server confirms the slot before anything is '
      'held.';
  static const String gallerySnackbarSuccess = 'Booking confirmed';
  static const String gallerySnackbarError = 'The slot was taken';
  static const String gallerySnackbarInfo = 'Battery reading saved';
  static const String galleryDialogAction = 'Open confirm sheet';
  static const String gallerySkeletonBody = 'A loading row keeps its shape.';
  static const String galleryShowError = 'Show error';
  static const String galleryShowEmpty = 'Show empty';
  static const String gallerySampleError = 'We could not load your bookings.';
  static const String galleryEmptyTitle = 'No bookings yet';
  static const String galleryEmptyBody =
      'A held slot appears here with its code and check-in time.';
  static const String galleryIllustrationUnplugged = 'Unplugged cable';
  static const String galleryIllustrationCar = 'Car with a question mark';
  static const String galleryIllustrationOffline = 'No signal';
  static const String galleryTabLabel = 'Gallery';
  static const String galleryThemeSwitch = 'Switch preview theme';
  static const String gallerySampleNotice =
      'Sample values below are for the gallery only. No account data is shown.';
  static const String galleryButtonPrimary = 'Reserve a port';
  static const String galleryButtonTonal = 'Update battery';
  static const String galleryButtonQuiet = 'Not now';
  static const String galleryButtonDanger = 'Cancel booking';
  static const String galleryButtonLoading = 'Reserving';
  static const String galleryButtonDisabled = 'Unavailable';
  static const String galleryChipAll = 'All';
  static const String galleryChipAvailable = 'Available now';
  static const String galleryChipFast = '60 kW+';
  static const String galleryFieldEmail = 'Email';
  static const String galleryFieldEmailHint = 'you@example.com';
  static const String galleryFieldPassword = 'Password';
  static const String galleryFieldPasswordHint = 'At least 8 characters';
  static const String galleryFieldError = 'Enter a valid email address.';
  static const String galleryFieldHelper = 'We only use this for receipts.';
  static const String galleryBatteryCaption = 'You said 52%';
  static const String galleryBatteryLowCaption = 'Low';
  static const String galleryTicketBooked = 'Booked';
  static const String galleryTimelineStartDetail = 'Depart 88% · 12:10 pm';
  static const String galleryTimelineStopDetail =
      'Arrive 24% · charge to 80% · 35 min';
  static const String galleryTimelineBackupDetail =
      'Backup · 6 km past the stop';
  static const String galleryTimelineArrivalDetail = 'Arrive 24% · 2:40 pm';
  static const String galleryReceiptTitle = 'Receipt';

  // ------------------------------------------------------------- timeline
  static const String journeyStart = 'Start';
  static const String journeyChargingStop = 'Charging stop';
  static const String journeyBackup = 'Backup stop';
  static const String journeyArrival = 'Arrival';

  // ------------------------------------------------------------- receipt
  static const String receiptEnergy = 'Energy';
  static const String receiptServiceFee = 'Service fee';
  static const String receiptGatewayFee = 'Gateway fee';
  static const String receiptAdjustment = 'Adjustment';
  static const String receiptTotal = 'Total';
  static const String receiptStartReading = 'Start reading';
  static const String receiptEndReading = 'End reading';
  static const String receiptVerifiedKwh = 'Verified energy';
}
