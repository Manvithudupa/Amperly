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
  static const String navDiscover = 'Discover';
  static const String navTrips = 'Trips';
  static const String navBookings = 'Bookings';
  static const String navMessages = 'Messages';
  static const String navProfile = 'Profile';
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
      connector.trim().isEmpty ? vehicle : '$vehicle · $connector';
  static const String discoverNoVehicle = 'No vehicle saved';
  static String discoverNearby(int count) => 'Chargers near you · $count';
  static String discoverCount(int count) =>
      count == 1 ? '1 charger' : '$count chargers';
  static const String discoverChange = 'Change';
  static const String discoverAddVehicle = 'Add';
  static const String discoverBatteryUnset =
      'Set your battery for range and charging checks.';
  static String discoverBatteryLevel(int percent) => 'Battery $percent%';
  static const String discoverBatteryAdd = 'Set battery';
  static const String discoverBatteryUpdate = 'Update';
  static const String discoverBatteryTitle = 'Set your battery';
  static const String discoverBatteryBody =
      'Take the reading from the dashboard. Amperly uses it for range checks '
      'and trip planning; it does not estimate the reading for you.';
  static const String discoverBatteryHint = 'Current battery (%)';
  static const String discoverBatteryInvalid =
      'Enter a battery reading between 0 and 100.';
  static String discoverBatterySaved(int percent) =>
      'Battery set to $percent%.';
  static const String discoverSearchHint = 'Where to?';
  static const String discoverAvailable = 'Available';
  static const String discoverBusy = 'Busy';
  static const String discoverMapMissingTitle = 'Map needs a Geoapify key';
  static const String discoverMapMissingBody =
      'Set GEOAPIFY_API_KEY in local.properties to draw chargers on the map.';
  static const String discoverHandleLabel = 'Drag to resize the charger list';
  static const String unnamedCharger = 'Unnamed charger';
  static const String addressNotPublished = 'Address not published';
  static const String connectorNotPublished = 'Connector not published';
  static const String powerNotPublished = 'Power not published';
  static const String priceNotPublished = 'Price not published';
  static const String discoverEmptyTitle = 'No chargers published yet.';
  static const String discoverEmptyBody =
      'When a host publishes a charger and an admin approves it, it appears '
      'here.';
  static const String discoverNoMatchesTitle = 'No chargers match.';
  static const String discoverNoMatchesBody =
      'Clear the filter to see every approved charger.';
  static const String discoverShowAll = 'Show all chargers';
  static const String discoverEmptyAction = 'Refresh the catalogue';
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
  static const String detailsDirectionsMode = 'Directions';
  static const String detailsDrive = 'Drive';
  static const String detailsWalk = 'Walk';
  static const String detailsNavigate = 'Navigate to this charger';
  static const String detailsLocating = 'Finding your location…';
  static const String detailsRouteFailed =
      'A route to this charger could not be planned. Try again.';
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
  static const String accountToolsTitle = 'Your surfaces';
  static const String accountEditName = 'Edit name';
  static const String accountEditNameTitle = 'Your display name';
  static const String accountEditNameBody =
      'Hosts and drivers see this name on bookings and messages.';
  static const String accountEditNameHint = 'Display name';
  static const String accountEditNameEmpty = 'Enter a name before saving.';
  static const String accountEditNameSaved = 'Name updated.';
  static const String accountEditNameFailed =
      'Your name was not updated. Check your connection and try again.';
  static const String accountDetailsTitle = 'Personal details';
  static const String accountOrganization = 'Organization';
  static const String accountIdLabel = 'Account ID';
  static const String accountChargingHistory = 'Charging history';

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
  static const String vehicleUnsavedTitle = 'Discard your changes?';
  static const String vehicleUnsavedBody =
      'This vehicle has edits that have not been saved.';
  static const String vehicleKeepEditing = 'Keep editing';
  static const String vehicleDiscard = 'Discard';
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
  static const String vehicleRangeLabel = 'Estimated range';
  static const String vehicleUsableLabel = 'Usable battery';
  static String vehicleRangeNote(int rangeKm) =>
      'About $rangeKm km of range from your figures.';

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
  static const String tripJourneyUnit = 'min';
  static const String tripRoadTitle = 'The road';
  static const String tripHowWeGotThis = 'How we got this';
  static const String tripHideDetails = 'Hide planning details';
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
  static const String tripStartNavigation = 'Start navigation';

  // ------------------------------------------------------------- navigation
  static const String navigationTitle = 'Navigation';
  static String navigationWalkingTo(String label) => 'Walking to $label';
  static const String navigationNextInstruction = 'Next instruction';
  static const String navigationNoSteps =
      'Follow the road route on the map to your destination.';
  static const String navigationArrivedTitle = 'You have arrived.';
  static const String navigationArrivedBody =
      'Navigation has ended at the destination. You can close this screen.';
  static const String navigationRemaining = 'Remaining';
  static const String navigationEta = 'Time left';
  static const String navigationStop = 'End navigation';
  static const String navigationDone = 'Done';
  static const String navigationArriveNow = 'I have arrived';
  static const String navigationSimulationNote =
      'Progress is simulated on the planned road route. This build does not '
      'track live GPS while navigating.';
  static String navigationStep(int step, int total) => 'Step $step of $total';
  static String navigationStopLine(int sequence, String name) =>
      'Stop $sequence · $name';

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
  static const String sessionDeliveredLabel = 'Delivered';
  static const String sessionMeterStartLabel = 'Meter start';
  static const String sessionReadEndForEnergy =
      'Read the end meter to see energy.';
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
  static const String chatReportThread = 'Report conversation';
  static const String chatBlockThread = 'Block this host';
  static const String chatReportTitle = 'Report this conversation?';
  static const String chatReportBody =
      'Amperly records the conversation for review. The thread stays open.';
  static const String chatReportConfirm = 'Report';
  static const String chatReported = 'Conversation reported.';
  static const String chatBlockTitle = 'Block this conversation?';
  static const String chatBlockBody =
      'Neither side can send messages in this thread after you block it.';
  static const String chatBlockConfirm = 'Block';
  static const String chatBlockedToast = 'Conversation blocked.';
  static const String chatFlagFailed =
      'That change was not saved. Check your connection and try again.';
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
  static const String chatOpen = 'Open';
  static const String chatYou = 'You';

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

  // ------------------------------------------------------------ host workspace
  static const String hostTitle = 'Hosting';
  static const String hostSubtitle =
      'Your chargers, their bookings and the money they earned.';
  static const String hostTabDashboard = 'Dashboard';
  static const String hostTabStations = 'Stations';
  static const String hostTabBookings = 'Bookings';
  static const String hostGreeting = 'Hosting as';
  static const String hostIncomeLabel = 'Income';
  static const String hostDisputesLabel = 'Disputes';
  static const String hostReservationsLabel = 'Reservations';
  static const String hostUtilizationLabel = 'Utilisation';
  static const String hostAnalyticsTitle = 'Performance';
  static const String hostSessionsTitle = 'Recent sessions';
  static const String hostNoSessions = 'No sessions have been settled yet.';
  static const String hostNoStationsTitle = 'No chargers yet';
  static const String hostNoStationsBody =
      'Register an existing charger. It stays pending until an administrator '
      'verifies it, so nothing is promised to drivers before then.';
  static const String hostAddStation = 'Register a charger';
  static const String hostStationFormTitle = 'Register a charger';
  static const String hostStationFormSubtitle =
      'The listing is submitted for verification.';
  static const String hostStationIntro =
      'Add the charger exactly as drivers will find it. Coordinates place it '
      'on the map; the listing is not published until it is approved.';
  static const String hostStationName = 'Charger name';
  static const String hostStationAddress = 'Address';
  static const String hostStationLatitude = 'Latitude';
  static const String hostStationLongitude = 'Longitude';
  static const String hostUseCurrentLocation = 'Use my current location';
  static const String hostLocating = 'Finding your location…';
  static const String hostLocationFailed =
      'Could not get a location fix. Enter the coordinates or tap the map in '
      'the native app, then try again.';
  static const String hostLocationRequired =
      'A charger needs a real latitude and longitude before it can be listed.';
  static const String hostLocationType = 'Location type';
  static const String hostMeterLevel = 'Meter level';
  static const String hostMeterLevel1 = 'Level 1 — visible meter';
  static const String hostMeterLevel2 = 'Level 2 — smart meter';
  static const String hostMeterLevel3 = 'Level 3 — discovery only';
  static const String hostOperatingHours = 'Published hours';
  static const String hostPriceLabel = 'Your price per kWh';
  static const String hostAccessRules = 'Access rules';
  static const String hostAccessHint = 'Contact the host on arrival.';
  static const String hostPortsTitle = 'Ports';
  static const String hostPortsBody =
      'Name the connector standards at this address. Each row keeps its own '
      'count, power and AC/DC type.';
  static const String hostConnectorLabel = 'Connector';
  static const String hostPortCountLabel = 'Ports';
  static const String hostPowerLabel = 'Power (kW)';
  static const String hostCurrentTypeLabel = 'Current';
  static const String hostAcLabel = 'AC';
  static const String hostDcLabel = 'DC';
  static const String hostAddPortType = 'Add another connector';
  static const String hostRemovePortType = 'Remove';
  static const String hostPlatformFees =
      'Amperly adds the service and gateway fees. They are fixed and shown to '
      'drivers before booking.';
  static const String hostSaveStation = 'Submit for verification';
  static const String hostSavingStation = 'Submitting…';
  static const String hostStationSaved =
      'Charger submitted. It appears here as pending review.';
  static const String hostStationSaveFailed =
      'The charger could not be saved. Nothing was published.';
  static const String hostNameRequired = 'Enter a charger name.';
  static const String hostAddressRequired = 'Enter the charger address.';
  static const String hostPriceInvalid =
      'Enter a price greater than zero per kWh.';
  static const String hostPortPowerInvalid =
      'Enter a power greater than zero for every port type.';
  static const String hostPortCountInvalid = 'Use at least one port.';
  static const String hostUnsavedTitle = 'Discard this listing?';
  static const String hostUnsavedBody =
      'The charger has not been submitted. Anything typed here will be lost.';
  static const String hostDiscard = 'Discard';
  static const String hostStationPending = 'Pending review';
  static const String hostStationApproved = 'Approved';
  static const String hostStationRejected = 'Rejected';
  static const String hostStationPaused = 'Paused';
  static const String hostStationLive = 'Live';
  static const String hostStationPause = 'Pause listings';
  static const String hostStationReopen = 'Reopen listing';
  static const String hostStationPausedToast = 'Listing paused.';
  static const String hostStationReopenedToast = 'Listing reopened.';
  static const String hostStationPauseFailed =
      'The listing could not be changed. Try again.';
  static const String hostMeterEvidence = 'Record meter reading';
  static const String hostMeterEvidenceTitle = 'Meter evidence';
  static const String hostMeterEvidenceBody =
      'Enter the start and end values from the station meter. This records '
      'evidence for a dispute; it does not bill a driver by itself.';
  static const String hostMeterStart = 'Start reading (kWh)';
  static const String hostMeterEnd = 'End reading (kWh)';
  static const String hostMeterSave = 'Save reading';
  static const String sessionInvalidReading =
      'Enter a valid reading. The ending value cannot be lower than the '
      'starting value.';
  static const String hostMeterSaved = 'Meter reading recorded.';
  static const String hostMeterSaveFailed =
      'The meter reading was not recorded. Check the values and try again.';
  static const String hostDeleteStation = 'Delete this charger';
  static const String hostDeleteStationTitle = 'Delete this charger?';
  static String hostDeleteStationBody(String name) =>
      '$name and its ports are removed permanently. This cannot be undone.';
  static String hostDeleteStationDone(String name) => '$name was deleted.';
  static String hostDeleteBlocked(String name) =>
      '$name still has an active booking, so it was not deleted.';
  static const String hostDeleteStationFailed =
      'The charger was not deleted. Nothing changed.';
  static const String hostPausedReason = 'Paused by the host';
  static const String hostDeleteBlockedTitle = 'Charger not deleted';
  static const String hostPortMeta = 'Ports';
  static const String hostPortAvailable = 'available';
  static const String hostPortSingular = 'port';
  static const String hostPortPlural = 'ports';
  static const String hostNoBookings = 'No bookings yet.';
  static const String hostNoBookingsBody =
      'A reservation made at one of your chargers will appear here.';
  static const String hostDriverFallback = 'Driver';
  static const String hostBookingShowCode = 'Show booking code';
  static const String hostBookingMessageDriver = 'Message driver';
  static const String hostBookingRequestReceipt = 'View receipt';
  static const String hostBookingCodeMissing =
      'No code was issued for this booking.';
  static const String hostBookingCodeTitle = 'Driver booking code';
  static const String hostChatOpeningFailed =
      'The conversation with this driver could not be opened.';
  static const String hostChatUnavailable =
      'This booking has no driver account to message.';
  static const String hostReportDriver = 'Report driver';
  static const String hostStatusLabel = 'Status';
  static const String hostRevenueValue = 'Revenue';
  static const String hostRepeatConsumers = 'Repeat drivers';
  static const String hostCancellationRate = 'Cancellation rate';
  static const String hostAverageSession = 'Average session';
  static const String hostRefunds = 'Refunds and adjustments';
  static const String hostActiveReservations = 'Active reservations';
  static const String hostPortsReported = 'Ports';
  static const String hostUtilizationNote =
      'Utilisation is estimated from recorded session time over a 12-hour '
      'bookable day per port. Amperly has no live charger telemetry.';
  static const String hostRevenueShort = 'Income';
  static const String hostSessionCount = 'Sessions completed';
  static const String hostEnergyDelivered = 'Energy delivered';
  static const String hostOpenDisputes = 'open';
  static const String hostNotAllowed =
      'Only the owner of this charger can manage it.';

  // ------------------------------------------------------------- admin desk
  static const String adminTitle = 'Admin desk';
  static const String adminSubtitle =
      'Verification, disputes and account reports.';
  static const String adminTabQueue = 'Queue';
  static const String adminTabReports = 'Reports';
  static const String adminQueueTitle = 'Listings to verify';
  static const String adminQueueEmpty = 'No listings are waiting for review.';
  static const String adminApprove = 'Approve';
  static const String adminDecline = 'Decline';
  static String adminApproved(String name) => '$name is approved and live.';
  static String adminDeclined(String name) => '$name was declined.';
  static const String adminDecisionFailed =
      'The decision was not recorded. Try again.';
  static const String adminPlatformSummary = 'Platform';
  static const String adminPendingCount = 'Pending listings';
  static const String adminDisputeCount = 'Disputes';
  static const String adminReportCount = 'Reports';
  static const String adminSessionsCount = 'Settled sessions';
  static const String adminEnergyCount = 'Energy delivered';
  static const String adminRevenueCount = 'Revenue';
  static const String adminRefundTotal = 'Refunds';
  static const String adminUtilizationCount = 'Utilisation';
  static const String adminNoticeLabel = 'Operations';
  static const String adminDisputesTitle = 'Disputes';
  static const String adminDisputesEmpty = 'No disputes are open.';
  static const String adminDisputeRefund = 'Refund energy charge';
  static const String adminDisputeFreeze = 'Hold payout';
  static const String adminDisputeWarning = 'Warning';
  static const String adminDisputeFine = 'Fine';
  static const String adminDisputeSuspend = 'Suspend';
  static const String adminDisputeBan = 'Ban';
  static const String adminConfirmRefundTitle = 'Refund this dispute?';
  static const String adminConfirmRefundBody =
      'The server refunds the invoice energy charge, resolves the consumer '
      'side and holds the host payout. This cannot be undone.';
  static const String adminRefundAction = 'Refund';
  static const String adminRefunded = 'Refund recorded.';
  static const String adminRefundFailed =
      'The refund was not recorded. Nothing changed.';
  static const String adminPayoutHeld = 'Host payout held.';
  static const String adminPayoutHoldFailed =
      'The payout could not be held. Try again.';
  static const String adminConfirmFreezeTitle = 'Hold this payout?';
  static const String adminConfirmFreezeBody =
      'The host payout stays frozen while the dispute is reviewed.';
  static const String adminHoldAction = 'Hold payout';
  static const String adminConfirmWarningTitle = 'Record a warning?';
  static const String adminConfirmWarningBody =
      'This records a warning against the host and resolves the dispute.';
  static const String adminConfirmFineTitle = 'Record a fine?';
  static String adminConfirmFineBody(String amount) =>
      'This records a $amount fine against the host and resolves the dispute.';
  static const String adminConfirmSuspendTitle = 'Suspend this host?';
  static const String adminConfirmSuspendBody =
      'This records a suspension and pauses the host engine on the server.';
  static const String adminConfirmBanTitle = 'Ban this host?';
  static const String adminConfirmBanBody =
      'This records a permanent ban, holds the payout and pauses the station. '
      'It cannot be undone from this screen.';
  static const String adminWarningAction = 'Warning';
  static const String adminFineAction = 'Fine';
  static const String adminSuspendAction = 'Suspend';
  static const String adminBanAction = 'Ban';
  static const String adminEnforcementRecorded = 'Enforcement recorded.';
  static const String adminEnforcementFailed =
      'The enforcement action was not recorded. Nothing changed.';
  static const String adminEnforcementNotePrefix = 'Admin decision';
  static const String adminFineLabel = 'Fine';
  static const String adminReportsTitle = 'Reports from consumers';
  static const String adminHostReportsTitle = 'Reports from hosts';
  static const String adminReportsEmpty = 'No reports filed.';
  static const String adminReportBy = 'Reported by';
  static const String adminReportAbout = 'About';
  static const String adminReportNoDetails = 'No details provided.';
  static const String adminReportWarning = 'Warn';
  static const String adminReportSuspend = 'Suspend';
  static const String adminReportBan = 'Ban';
  static const String adminReportResolved = 'Resolved';
  static const String adminReportOpen = 'Open';
  static const String adminReportResolutionFailed =
      'The report decision was not recorded. Try again.';
  static const String adminNoTarget = 'No account could be resolved';
  static const String adminNoTargetBody =
      'This report does not identify a host or driver the desk can act against.';
  static const String adminUnknownAccount = 'Unknown account';
  static const String adminSuspendTitle = 'Suspend this account';
  static const String adminSuspendBody =
      'Choose how long the suspension lasts. The account is notified.';
  static String adminSuspendSuggested(String option) =>
      'Suggested from the account’s history: $option.';
  static const String adminSuspend1d = '1 day';
  static const String adminSuspend7d = '7 days';
  static const String adminSuspend30d = '30 days';
  static const String adminActionRecorded = 'Decision recorded.';
  static const String adminNoticeSuspendTitle = 'Your account is suspended';
  static String adminNoticeSuspendBody(String type, String until) =>
      'A $type report was upheld. Your account is suspended until $until.';
  static const String adminNoticeBanTitle = 'Your account is blocked';
  static String adminNoticeBanBody(String type) =>
      'A $type report was upheld. Your account has been permanently blocked.';
  static const String adminNoticeWarningTitle = 'You received a warning';
  static String adminNoticeWarningBody(String type) =>
      'A $type report was upheld. This is a formal warning.';
  static const String adminReportNotePrefix = 'Report';
  static String adminReportNote(String action, String reportType) =>
      '$adminReportNotePrefix: $reportType ($action)';
  static const String adminNotAllowed =
      'This desk is only available to platform administrators.';
  static const String adminNotAllowedTitle = 'Administrator access only';
  static const String adminEvidenceTitle = 'Meter evidence';
  static const String adminEvidenceNone = 'No meter evidence uploaded.';
  static const String adminRefundAmount = 'Refund amount';
  static const String adminPayoutFrozen = 'Payout held';
  static const String adminDisputeReason = 'Reason';
  static const String adminDisputeResolution = 'Resolution';
  static const String adminDisputeHost = 'Host';
  static const String adminDisputeConsumer = 'Driver';
  static const String adminStationFallback = 'Charger';
  static const String adminApproveBody =
      'Approving makes an eligible charger visible in Discover.';
  static const String adminDeclineBody =
      'Declining keeps the charger out of the catalogue.';
  static const String adminNoQueueAction = 'No review action available';

  // ------------------------------------------------------------ notifications
  static const String notificationsTitle = 'Notifications';
  static const String notificationsSubtitle =
      'Booking, report and account updates.';
  static const String notificationsEmptyTitle = 'No notifications';
  static const String notificationsEmptyBody =
      'Updates about your bookings and account appear here.';
  static const String notificationsMarkAll = 'Mark all as read';
  static const String notificationsAllRead = 'All notifications are read.';
  static const String notificationsMarkedAll = 'All notifications marked read.';
  static const String notificationsMarkFailed =
      'Notifications could not be marked read. Try again.';
  static const String notificationsUnread = 'Unread';
  static const String notificationsOpen = 'Open';
  static const String notificationsActionFailed =
      'That notification could not be opened.';

  // ------------------------------------------------------------------ reports
  static const String reportTitle = 'Report an issue';
  static const String reportSubtitle =
      'Reports go to the Amperly desk for review.';
  static const String reportTypeLabel = 'What happened?';
  static const String reportDetailsLabel = 'Details (optional)';
  static const String reportDetailsHint =
      'Add anything that helps the desk review this.';
  static const String reportSubmit = 'Submit report';
  static const String reportSubmitting = 'Submitting…';
  static const String reportSubmitted = 'Report submitted.';
  static const String reportFailed = 'The report was not submitted. Try again.';
  static const String reportNoDetails = 'No details provided.';
  static const String reportHostContext = 'Report a driver';
  static const String reportConsumerContext = 'Report a charger or host';
  static const String reportAboutCharger = 'About this charger';
  static const String reportAboutDriver = 'About this driver';
  static const String reportMissingTarget =
      'This report does not name a charger or booking.';
  static const String reportTypeOther = 'Something else';
  static const String reportTypeUnsafe = 'Safety concern';
  static const String reportTypeNoShow = 'Driver did not arrive';
  static const String reportTypeDamage = 'Equipment damage';
  static const String reportTypeAbuse = 'Abusive behaviour';
  static const String reportTypePayment = 'Payment outside the app';
  static const String reportTypeMeter = 'Meter or billing issue';
  static const String reportTypeAccess = 'Access problem';
  static const String reportTypeCleanliness = 'Cleanliness';
  static const String reportTypeStation = 'Charger not as listed';
  static const String reportTypeHostConduct = 'Host conduct';

  // ------------------------------------------------------------ safety / SOS
  static const String safetyTitle = 'Session safety';
  static const String safetySubtitle =
      'Trusted contacts and a record of safety events.';
  static const String safetyDemoNotice =
      'Amperly is not an emergency service. In an emergency, call local '
      'emergency services. SOS here records an event for your account only.';
  static const String safetySosTitle = 'Record an SOS';
  static const String safetySosBody =
      'This records an SOS event on your account. It does not call anyone and '
      'does not dispatch help.';
  static const String safetySosConfirm = 'Record SOS';
  static const String safetySosButton = 'Record SOS';
  static const String safetySosRecorded = 'SOS event recorded.';
  static const String safetySosFailed =
      'The SOS event was not recorded. Try again.';
  static const String safetyTrustedTitle = 'Trusted contacts';
  static const String safetyTrustedEmpty =
      'Add someone you would want to share a charging stop with.';
  static const String safetyAddContact = 'Add contact';
  static const String safetyContactName = 'Name';
  static const String safetyContactPhone = 'Phone';
  static const String safetyContactInvalid =
      'Enter a name and a phone number with at least 6 digits.';
  static const String safetyContactSaved = 'Trusted contact added.';
  static const String safetyContactSaveFailed =
      'The contact could not be added. Try again.';
  static const String safetyContactRemoved = 'Trusted contact removed.';
  static const String safetyContactRemoveFailed =
      'The contact could not be removed. Try again.';
  static const String safetyDeleteContactTitle = 'Remove this contact?';
  static String safetyDeleteContactBody(String name) =>
      '$name will no longer be able to receive a shared location from you.';
  static const String safetyRemove = 'Remove';
  static const String safetyCall = 'Call';
  static const String safetyCallFailed =
      'This device could not open the phone app for that number.';
  static const String safetyShareTitle = 'Share a charging stop';
  static const String safetyShareBody =
      'This records a one-hour live-location sharing window for the first '
      'trusted contact. Amperly does not transmit GPS in this build.';
  static const String safetyShareStart = 'Start one-hour sharing';
  static const String safetyShareStop = 'Stop sharing';
  static const String safetyShareStarted = 'Sharing window started.';
  static const String safetyShareStopped = 'Sharing window stopped.';
  static const String safetyShareFailed =
      'The sharing window could not be changed. Try again.';
  static const String safetyShareNeedsContact =
      'Add a trusted contact before sharing a stop.';
  static String safetyShareActive(String phone, String until) =>
      'One-hour sharing is active with $phone until $until.';
  static const String safetyShareInactive =
      'No live-location sharing window is active.';
  static const String safetyShareActiveLabel = 'Live-location sharing is on.';
  static const String safetyHistoryTitle = 'Safety history';
  static const String safetyHistoryEmpty = 'No safety events recorded.';
  static String safetyHistoryLine(String type, String date) => '$type · $date';
  static const String safetyHistoryActiveSuffix = ' · sharing active';
  static const String safetyHistoryEndedSuffix = ' · sharing ended';
  static const String safetyNoStation =
      'This is not tied to a charger. Open it from a booking to include the '
      'charger.';
  static const String safetyContactCount = 'contacts';
  static const String safetyEventSos = 'SOS';
  static const String safetyEventSharing = 'Live location';
}
