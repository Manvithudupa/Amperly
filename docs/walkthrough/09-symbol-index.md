# 09 — Symbol index

Generated from the working tree. Each entry is `line: signature`; use it to resolve a function named in reports 02–05 to its exact declaration line. Class/interface/enum declarations and method/constructor first lines are included; multi-line signatures show their first line, and anonymous/lambda bodies are not listed.


## app/src/main/java/com/amperly/app/MainActivity.java

```
78: public class MainActivity extends AppCompatActivity
160: protected void onCreate(Bundle savedInstanceState) {
175: public void handleOnBackPressed() {
218: protected void onSaveInstanceState(@NonNull Bundle outState) {
225: private void restoreTabs(@Nullable Bundle savedInstanceState) {
249: private void handleBack() {
264: private boolean isAtHomeScreen() {
291: protected void onNewIntent(android.content.Intent intent) {
297: private void handleDeepLink(android.content.Intent intent) {
316: private void setChromeVisible(boolean visible) {
323: private void applyWindowInsets() {
371: private void applyKeyboardInsets() {
401: private void setNavWanted(boolean wanted) {
406: private void applyNavVisibility() {
415: private boolean isNavShowing() {
419: private void startBackend() {
444: public void showSignIn() {
456: public void onSignedIn(User user) {
486: public void onSignedOut() {
494: private void restoreSession() {
536: private void syncAfterSignIn() {
569: public boolean onCreateOptionsMenu(Menu menu) {
582: private View buildProfileBadge() {
607: private void renderProfileBadge() {
632: public void refreshProfileBadge() {
636: private void showProfileMenu(View anchor) {
668: public boolean onPrepareOptionsMenu(Menu menu) {
677: public boolean onOptionsItemSelected(MenuItem item) {
693: private void makeToolbarHome(Toolbar toolbar) {
708: private void wireHome(Toolbar toolbar, View.OnClickListener home) {
728: public void goHome() {
736: private int homeItemId(String role) {
747: private static String initialsOf(@Nullable String name) {
765: private void confirmSignOut() {
775: private void performSignOut() {
788: private void selectRole(String role) {
801: public void switchRole(String role) {
810: private void applyRole(String role) {
819: private void applyRole(String role, int initialItemId) {
838: private void buildNavigation(String role, int initialItemId) {
889: private void landOnNavigation(int initialItemId, int defaultItemId) {
919: private void selectNavigationItem(int itemId) {
931: private void loadNavigationItem(int itemId) {
942: private boolean loadConsumerScreen(int itemId) {
966: private void openTripsTab() {
977: private boolean loadHostScreen(int itemId) {
995: private boolean loadAdminScreen(int itemId) {
1020: public String currentTabBackStackName() {
1030: private void popCurrentTabPages() {
1045: private void leaveCurrentTab(@NonNull FragmentManager manager, @Nullable String targetTag) {
1078: private static boolean isStackFiledUnder(@NonNull FragmentManager manager, @NonNull String name) {
1095: private void loadRoot(Fragment fragment, String tag) {
1183: private void replaceTabRoot(Fragment fragment, String tag) {
1208: private void resetTabs() {
1234: public void showTripNavigation(@NonNull Bundle args) {
1257: public void showTripPlanner() {
```

## app/src/main/java/com/amperly/app/car/AmperlyCarAppService.java

```
8: public class AmperlyCarAppService extends CarAppService {
12: public HostValidator createHostValidator() {
18: public Session onCreateSession() {
```

## app/src/main/java/com/amperly/app/car/AmperlyCarSession.java

```
23: public class AmperlyCarSession extends Session {
29: public Screen onCreateScreen(@NonNull Intent intent) {
51: public void onDestroy(@NonNull LifecycleOwner owner) {
```

## app/src/main/java/com/amperly/app/car/CarBridge.java

```
27: public final class CarBridge {
40: public Snapshot(RoutePlan plan, Vehicle vehicle, Reservation reservation,
55: public RoutePlan getPlan() { return plan; }
56: public Vehicle getVehicle() { return vehicle; }
57: public Reservation getReservation() { return reservation; }
58: public List<ChargerStation> getReachableStations() { return reachableStations; }
59: public ChargerStation getRecommendedStation() { return recommendedStation; }
60: public String getRecommendedDetail() { return recommendedDetail; }
61: public int getCurrentSoc() { return currentSoc; }
62: public boolean isSocAuthoritative() { return socAuthoritative; }
63: public String getNoSafeChargerMessage() { return noSafeChargerMessage; }
65: public String routeTitle() {
73: public String summaryLine() {
87: public interface Callback<T> {
88: void onResult(T value);
91: private CarBridge() {
94: public static void load(AmperlyRepository repo, Callback<Snapshot> callback) {
140: public static void applyBatteryUpdate(AmperlyRepository repo, int actualSoc,
184: public static void reserveNextFreeSlot(AmperlyRepository repo, String stationId,
```

## app/src/main/java/com/amperly/app/car/CarScreenFactory.java

```
13: public class CarScreenFactory {
15: public enum ScreenType {
25: public static Screen createScreen(ScreenType type, CarContext carContext) {
29: public static Screen createScreen(ScreenType type, CarContext carContext, String stationId) {
```

## app/src/main/java/com/amperly/app/car/screen/CarMap.java

```
44: public final class CarMap implements SurfaceCallback {
52: public Pin(double latitude, double longitude, @NonNull String color) {
81: public CarMap(@NonNull CarContext carContext) {
86: public void start() {
95: public void stop() {
110: public void show(double latitude, double longitude, int zoom, @NonNull List<Pin> pins) {
120: public static Pin station(double latitude, double longitude) {
126: public static Pin destination(double latitude, double longitude) {
133: public void onSurfaceAvailable(@NonNull SurfaceContainer container) {
145: public void onVisibleAreaChanged(@NonNull Rect visibleArea) {
150: public void onStableAreaChanged(@NonNull Rect stableArea) {
155: public void onSurfaceDestroyed(@NonNull SurfaceContainer container) {
161: private void render() {
189: private void draw() {
212: private String buildUrl() {
237: private static Bitmap download(@NonNull String url) {
250: private static String coordinate(double value) {
```

## app/src/main/java/com/amperly/app/car/screen/CarSettingsScreen.java

```
20: public class CarSettingsScreen extends Screen {
22: public CarSettingsScreen(@NonNull CarContext carContext) {
28: public Template onGetTemplate() {
```

## app/src/main/java/com/amperly/app/car/screen/ChargerDetailsCarScreen.java

```
27: public class ChargerDetailsCarScreen extends Screen {
34: public ChargerDetailsCarScreen(@NonNull CarContext carContext, String stationId) {
42: public Template onGetTemplate() {
```

## app/src/main/java/com/amperly/app/car/screen/ChargerListCarScreen.java

```
21: public class ChargerListCarScreen extends Screen {
26: public ChargerListCarScreen(@NonNull CarContext carContext) {
33: public Template onGetTemplate() {
73: public void setStations(List<ChargerStation> stations) {
78: public static String portSummary(List<com.amperly.app.data.local.entity.ChargerPort> ports) {
```

## app/src/main/java/com/amperly/app/car/screen/NavigationCarScreen.java

```
41: public class NavigationCarScreen extends Screen {
47: public NavigationCarScreen(@NonNull CarContext carContext) {
54: public Template onGetTemplate() {
130: private CarText tripText(@NonNull RoutePlan plan) {
142: private String nextStopName() {
```

## app/src/main/java/com/amperly/app/car/screen/ReservationStatusCarScreen.java

```
21: public class ReservationStatusCarScreen extends Screen {
28: public ReservationStatusCarScreen(@NonNull CarContext carContext) {
35: public Template onGetTemplate() {
```

## app/src/main/java/com/amperly/app/car/screen/RouteOverviewCarScreen.java

```
41: public class RouteOverviewCarScreen extends Screen {
50: public RouteOverviewCarScreen(@NonNull CarContext carContext) {
56: public void onDestroy(@NonNull LifecycleOwner owner) {
65: public Template onGetTemplate() {
93: private void updateMap() {
136: private ListTemplate buildSidebar() {
245: private int snapshotReachableCount() {
250: private ActionStrip buildActionStrip() {
```

## app/src/main/java/com/amperly/app/car/screen/SoCUpdateCarScreen.java

```
20: public class SoCUpdateCarScreen extends Screen {
26: public SoCUpdateCarScreen(@NonNull CarContext carContext) {
33: public Template onGetTemplate() {
```

## app/src/main/java/com/amperly/app/car/screen/TripHistoryCarScreen.java

```
23: public class TripHistoryCarScreen extends Screen {
29: public TripHistoryCarScreen(@NonNull CarContext carContext) {
36: public Template onGetTemplate() {
```

## app/src/main/java/com/amperly/app/car/screen/VehicleCarScreen.java

```
20: public class VehicleCarScreen extends Screen {
26: public VehicleCarScreen(@NonNull CarContext carContext) {
33: public Template onGetTemplate() {
```

## app/src/main/java/com/amperly/app/communication/ChatManager.java

```
26: public class ChatManager {
38: private ChatManager() {
41: public static String maskPhoneNumber(String phone) {
54: public static String sanitizeText(String text, String ownPhone, String otherPhone) {
70: public static boolean containsOffPlatformPaymentRequest(String text) {
86: public static long expiryFor(@Nullable Reservation reservation, long nowMs) {
91: public static CommunicationThread createThread(Reservation reservation, User consumer, User host) {
115: public static CommunicationThread reuseForReservation(@Nullable CommunicationThread thread,
138: public static ChatMessage createMessage(String threadId, String reservationId, String senderId,
152: public static boolean isThreadOpen(CommunicationThread thread, long nowMs) {
156: public static String expiryLabel(long expiresAtMs) {
```

## app/src/main/java/com/amperly/app/core/common/AppConstants.java

```
3: public class AppConstants {
```

## app/src/main/java/com/amperly/app/core/common/Formatters.java

```
11: public final class Formatters {
13: private Formatters() {
16: public static String money(double amount) {
20: public static String moneyShort(double amount) {
24: public static String kwh(double value) {
28: public static String percent(int value) {
39: public static String percent(double value) {
49: public static String minutes(int totalMinutes) {
58: public static String clock(long timeMs) {
62: public static String dateTime(long timeMs) {
66: public static String dayAndSlot(long startMs, long endMs) {
82: private static boolean sameDay(Calendar a, Calendar b) {
88: public static String agoFromNow(long thenMs) {
106: public static String minutesFromMidnight(int minutesFromMidnight) {
118: public static String connectorType(@Nullable String stored) {
142: public static String connectorTypes(@Nullable String storedCsv) {
161: public static String approvalStatus(@Nullable String stored) {
179: public static String verificationLevel(@Nullable String stored) {
197: public static String portStatus(@Nullable String stored) {
218: public static String bookingStatus(@Nullable String stored) {
251: private static String humanize(String stored) {
```

## app/src/main/java/com/amperly/app/core/common/GeoUtils.java

```
8: public final class GeoUtils {
13: private GeoUtils() {
17: public static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
27: public static double distanceToRouteKm(double lat, double lng,
41: public static double fractionAlongRoute(double lat, double lng,
47: private static double[] projectFraction(double lat, double lng,
73: public static double detourKm(double distanceFromRouteKm) {
77: public static int detourMinutes(double detourKm) {
81: public static int drivingMinutes(double distanceKm) {
86: public static double bearingDegrees(double lat1, double lng1, double lat2, double lng2) {
95: public static String compassLabel(double bearingDegrees) {
```

## app/src/main/java/com/amperly/app/core/common/GeoapifyErrors.java

```
14: public final class GeoapifyErrors {
16: private GeoapifyErrors() {
21: public static String httpFailure(int code) {
```

## app/src/main/java/com/amperly/app/core/common/MapConfig.java

```
22: public final class MapConfig {
33: private MapConfig() {
37: public static boolean isConfigured() {
42: public static boolean isEnabled() {
48: public static String apiKey() {
58: public static String styleUrl() {
72: public static String withKey(@NonNull String url) {
85: public static String setupMessage(@NonNull Context context) {
```

## app/src/main/java/com/amperly/app/core/common/RequestSequence.java

```
12: public final class RequestSequence {
17: public synchronized int next() {
23: public synchronized boolean isCurrent(int token) {
```

## app/src/main/java/com/amperly/app/core/common/UserMessages.java

```
21: public final class UserMessages {
26: public enum Kind {
42: private UserMessages() {
46: public static String from(Context context, @Nullable Throwable error, @StringRes int fallbackRes) {
59: public static String fromText(Context context, @Nullable String technicalText,
77: public static Kind classify(@Nullable Throwable error, @Nullable String technicalText) {
104: public static Kind classify(int httpCode, @Nullable String technicalText) {
181: public static String messageFor(Context context, Kind kind, @StringRes int fallbackRes) {
213: private static boolean containsAny(String text, String... needles) {
```

## app/src/main/java/com/amperly/app/core/common/ValidationUtils.java

```
5: public class ValidationUtils {
7: public static boolean isValidSoc(int soc) {
11: public static boolean isValidMeterReading(double startReading, double endReading) {
15: public static boolean isValidEmail(String email) {
19: public static boolean isValidPhone(String phone) {
```

## app/src/main/java/com/amperly/app/core/location/LocationProvider.java

```
26: public final class LocationProvider {
28: public interface LocationCallback {
29: void onLocationRetrieved(double latitude, double longitude);
32: default void onLocationUnavailable() {
36: private LocationProvider() {
52: public static boolean hasLocationPermission(Context context) {
66: public static boolean hasAskedForPermission(Context context) {
73: public static void markPermissionAsked(Context context) {
85: public static void requestCurrentLocation(Context context, LocationCallback callback) {
116: public static double[] lastKnownFix() {
121: private static void rememberFix(double latitude, double longitude) {
126: private static void useLastKnown(FusedLocationProviderClient client, LocationCallback callback) {
```

## app/src/main/java/com/amperly/app/core/map/MapContainerView.java

```
19: public class MapContainerView extends FrameLayout {
21: public MapContainerView(@NonNull Context context) {
25: public MapContainerView(@NonNull Context context, @Nullable AttributeSet attrs) {
29: public MapContainerView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
34: public boolean onInterceptTouchEvent(MotionEvent ev) {
```

## app/src/main/java/com/amperly/app/core/map/MapPanel.java

```
67: public final class MapPanel {
70: public interface MarkerTap {
71: void onStation(@Nullable ChargerStation station);
75: public interface MapTap {
76: void onPoint(double latitude, double longitude);
80: public interface Ready {
81: void onReady(@NonNull MapPanel panel);
131: private MapPanel(@NonNull MapView mapView, @NonNull Context appContext) {
142: public static void attach(@NonNull Fragment parent, @Nullable ViewGroup container,
185: private static MapView createMapView(@NonNull Context context) {
195: private void bindLifecycle(@NonNull Fragment parent, @NonNull ViewGroup container) {
235: private void onMapReady(@NonNull MapLibreMap readyMap, @NonNull Ready callback) {
252: private static void showSetupNotice(@NonNull Fragment parent, @NonNull ViewGroup container) {
279: private void installSourcesAndLayers(@NonNull Style loaded) {
333: public void setMarkerTapListener(@Nullable MarkerTap listener) {
337: public void setMapTapListener(@Nullable MapTap listener) {
342: public void centerOn(double latitude, double longitude, float zoom) {
357: public void followUser(double latitude, double longitude, float zoom) {
370: public void plotDriverPosition(double latitude, double longitude) {
381: public void plotStations(@Nullable List<ChargerStation> stations,
435: public void plotRoute(@Nullable DirectionsRoute route, double originLat, double originLng,
488: public void plotPicker(double latitude, double longitude, @Nullable String label,
501: public void movePickerTo(double latitude, double longitude) {
512: public double[] pickerPosition() {
519: private boolean handleMapClick(@NonNull LatLng point) {
552: private void clearAll() {
561: private void setSource(@NonNull String sourceId, @NonNull List<Feature> features) {
573: private void frameTo(@NonNull LatLngBounds.Builder bounds, double fallbackLat,
590: private static Feature stationFeature(@NonNull ChargerStation station, boolean highlighted) {
596: private static Feature pickerFeature(double latitude, double longitude, @Nullable String label) {
607: private static Feature pointFeature(@Nullable String id, @NonNull String color,
619: private static FeatureCollection emptyCollection() {
624: private static List<Feature> single(@NonNull Feature feature) {
631: private static List<Feature> listOf(@NonNull Feature... features) {
641: private static String hex(int color) {
646: static boolean isPlotable(@Nullable ChargerStation station) {
```

## app/src/main/java/com/amperly/app/core/map/StationMarkerModel.java

```
21: public final class StationMarkerModel {
34: private StationMarkerModel() {
41: public static float hue(@NonNull ChargerStation station, boolean highlighted) {
64: public static int color(@NonNull ChargerStation station, boolean highlighted) {
75: public static int argbFromHue(float hue, float saturation, float value) {
127: public static String snippet(@NonNull ChargerStation station) {
142: public static String supportsBillingLabel(@NonNull ChargerStation station) {
```

## app/src/main/java/com/amperly/app/core/map/StationVisibility.java

```
22: public final class StationVisibility {
24: private StationVisibility() {
28: public static boolean isPlotable(@Nullable ChargerStation station) {
42: public static boolean hasValidCoordinates(double latitude, double longitude) {
```

## app/src/main/java/com/amperly/app/core/nav/GeoapifyNavigationProvider.java

```
33: public final class GeoapifyNavigationProvider implements NavigationProvider {
52: public GeoapifyNavigationProvider() {
56: public GeoapifyNavigationProvider(@NonNull GeoapifyRoutingClient.TravelMode defaultMode) {
61: public GeoapifyNavigationProvider(@NonNull Context context) {
65: private GeoapifyNavigationProvider(@Nullable Context appContext,
72: public void calculateRoute(@NonNull RouteRequest request, @NonNull RouteCallback callback) {
77: public void recalculate(@NonNull RouteRequest request, @NonNull RouteCallback callback) {
81: private void calculate(@NonNull RouteRequest request, @NonNull RouteCallback callback) {
86: public void onRoute(@NonNull DirectionsRoute route) {
92: public void onError(@NonNull String message) {
106: public void startNavigation(@NonNull NavigationRequest request, @NonNull NavigationCallback callback) {
118: public void updateProgress(double lat, double lng, double remainingKm, int remainingMinutes,
129: public void applyReroute(@NonNull DirectionsRoute newRoute, @Nullable NavigationCallback callback) {
141: public void markArrived(@Nullable NavigationCallback callback) {
154: public void stopNavigation() {
160: public NavigationState getCurrentNavigationState() {
```

## app/src/main/java/com/amperly/app/core/nav/NavigationProvider.java

```
20: public interface NavigationProvider {
23: final class RouteRequest {
32: public RouteRequest(double originLat, double originLng, double destinationLat,
38: private RouteRequest(double originLat, double originLng, double destinationLat,
56: public static RouteRequest toAddress(double originLat, double originLng,
62: public double getOriginLat() { return originLat; }
63: public double getOriginLng() { return originLng; }
64: public double getDestinationLat() { return destinationLat; }
65: public double getDestinationLng() { return destinationLng; }
70: public boolean hasDestinationQuery() {
79: final class RouteResult {
86: public RouteResult(DirectionsRoute route, RouteRequest request, String providerName,
98: public long getCalculatedAtMs() { return calculatedAtMs; }
99: public boolean isStale() { return stale; }
102: interface RouteCallback {
103: void onRoute(@NonNull RouteResult result);
105: void onError(@NonNull String message);
109: final class NavigationRequest {
113: public NavigationRequest(@NonNull RouteResult route, int audioGuidanceFlags) {
119: public int getAudioGuidanceFlags() { return audioGuidanceFlags; }
122: interface NavigationCallback {
123: void onStarted(@NonNull NavigationState state);
125: void onRerouted(@NonNull NavigationState state);
127: void onArrived(@NonNull NavigationState state);
129: void onStopped();
131: void onError(@NonNull String message);
135: void calculateRoute(@NonNull RouteRequest request, @NonNull RouteCallback callback);
138: void startNavigation(@NonNull NavigationRequest request, @NonNull NavigationCallback callback);
141: void recalculate(@NonNull RouteRequest request, @NonNull RouteCallback callback);
144: void stopNavigation();
148: NavigationState getCurrentNavigationState();
```

## app/src/main/java/com/amperly/app/core/nav/NavigationState.java

```
13: public final class NavigationState {
17: public static NavigationState idle() {
32: public NavigationState(boolean active, @Nullable String sessionId,
48: public boolean isActive() { return active; }
58: public double getRemainingDistanceKm() { return remainingDistanceKm; }
60: public int getRemainingMinutes() { return remainingMinutes; }
63: public int getTravelledPercent() { return travelledPercent; }
65: public long getUpdatedAtMs() { return updatedAtMs; }
67: public boolean hasArrived() { return arrived; }
71: public NavigationState movedTo(double lat, double lng, double remainingKm, int remainingMin,
79: public NavigationState withRoute(@NonNull DirectionsRoute newRoute) {
```

## app/src/main/java/com/amperly/app/core/nav/Navigator.java

```
20: public final class Navigator {
22: private Navigator() {
25: public static void open(@NonNull Fragment from, @NonNull Fragment target, String tag) {
47: private static String backStackName(@NonNull FragmentActivity activity, String tag) {
57: public static void openRoot(@NonNull FragmentActivity activity, @NonNull Fragment target, String tag) {
64: public static boolean pop(@NonNull Fragment from) {
74: public static void navigateTo(Context context, double latitude, double longitude, String label) {
96: public static void dial(Context context, String number) {
```

## app/src/main/java/com/amperly/app/core/nav/RouteProgress.java

```
17: public final class RouteProgress {
19: private RouteProgress() {
26: public static double fractionAlong(@NonNull List<double[]> points, double lat, double lng) {
45: public static double remainingKm(@NonNull DirectionsRoute route, double fraction) {
51: public static int remainingMinutes(@NonNull DirectionsRoute route, double fraction) {
60: public static DirectionsRoute.Step nextStep(@NonNull DirectionsRoute route, double fraction) {
```

## app/src/main/java/com/amperly/app/core/nav/TabBackStackHost.java

```
13: public interface TabBackStackHost {
20: String currentTabBackStackName();
```

## app/src/main/java/com/amperly/app/core/nav/TripNavigationHost.java

```
15: public interface TripNavigationHost {
18: void showTripNavigation(@NonNull Bundle args);
21: void showTripPlanner();
```

## app/src/main/java/com/amperly/app/core/places/GeoapifyGeocoder.java

```
40: public final class GeoapifyGeocoder {
42: public interface Callback {
43: void onAddress(@NonNull String formattedAddress);
45: void onError(@NonNull String message);
49: public interface ForwardCallback {
50: void onResult(@NonNull PlacesAutocomplete.Selection selection);
52: void onError(@NonNull String message);
69: protected boolean removeEldestEntry(Map.Entry<String, String> eldest) {
74: private GeoapifyGeocoder() {
78: public static void reverseGeocode(@NonNull Context context, double latitude, double longitude,
116: public static void forward(@NonNull Context context, @NonNull String text, double biasLat,
148: static String autocompleteUrl(@NonNull String text, int limit, double biasLat, double biasLng) {
163: public static String parseFirstAddress(@Nullable String json) {
168: private static String get(@NonNull String url) throws Exception {
181: static String cacheKey(double latitude, double longitude) {
185: private static String enc(String value) {
```

## app/src/main/java/com/amperly/app/core/places/GeoapifyPlaceParser.java

```
27: public final class GeoapifyPlaceParser {
29: private GeoapifyPlaceParser() {
38: public static List<PlacesAutocomplete.Selection> parseSuggestions(@Nullable String json, int limit) {
66: public static PlacesAutocomplete.Selection parseFirstMatch(@Nullable String json) {
73: public static String parseFirstFormattedAddress(@Nullable String json) {
93: private static PlacesAutocomplete.Selection toSelection(@NonNull JsonObject feature) {
128: private static JsonArray features(@NonNull String json) {
142: private static JsonObject object(@NonNull JsonObject parent, @NonNull String key) {
148: private static JsonArray array(@NonNull JsonObject parent, @NonNull String key) {
154: private static String string(@NonNull JsonObject parent, @NonNull String key) {
167: private static Double number(@NonNull JsonObject parent, @NonNull String key) {
```

## app/src/main/java/com/amperly/app/core/places/PlacesAutocomplete.java

```
56: public final class PlacesAutocomplete {
79: public Selection(String placeId, String label, String address, double latitude,
91: public double getLatitude() { return latitude; }
92: public double getLongitude() { return longitude; }
96: public interface Listener {
97: void onPlaceSelected(@NonNull Selection selection);
100: void onSelectionCleared();
107: default void onLookupFailed(@NonNull String message) {
111: private PlacesAutocomplete() {
115: public static boolean isAvailable(@NonNull Context context) {
123: public static void bind(@NonNull Context context, @NonNull AutoCompleteTextView field,
146: public Filter getFilter() {
149: protected FilterResults performFiltering(CharSequence constraint) {
157: protected void publishResults(CharSequence constraint, FilterResults results) {
165: public View getView(int position, @Nullable View convertView,
198: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
202: public void onTextChanged(CharSequence s, int start, int before, int count) {
213: public void afterTextChanged(Editable s) {
254: private static void search(@NonNull Context appContext, @NonNull String query, int token,
305: private static String fetch(@NonNull String url) throws Exception {
```

## app/src/main/java/com/amperly/app/core/routing/DirectionsRoute.java

```
17: public final class DirectionsRoute {
28: public Step(String instruction, String distanceText, String durationText, String maneuver,
40: public String getInstruction() { return instruction; }
43: public String getDistanceText() { return distanceText; }
46: public String getDurationText() { return durationText; }
50: public String getManeuver() { return maneuver; }
52: public double getStartLat() { return startLat; }
54: public double getStartLng() { return startLng; }
66: public DirectionsRoute(List<double[]> points, double distanceKm, int durationMinutes,
81: public List<double[]> getPoints() { return points; }
84: public double getOriginLat() { return points.isEmpty() ? 0 : points.get(0)[0]; }
86: public double getOriginLng() { return points.isEmpty() ? 0 : points.get(0)[1]; }
89: public double getDestinationLat() {
93: public double getDestinationLng() {
97: public double getDistanceKm() { return distanceKm; }
99: public int getDurationMinutes() { return durationMinutes; }
102: public int getDurationInTrafficMinutes() { return durationInTrafficMinutes; }
111: public List<Step> getSteps() { return steps; }
114: public boolean isApproximate() { return approximate; }
117: public int getEffectiveDurationMinutes() {
123: public static DirectionsRoute straightLineEstimate(double fromLat, double fromLng, double toLat,
140: private static double[] geodesicPoint(double lat1, double lon1, double lat2, double lon2,
162: public static String describeError(String raw) {
```

## app/src/main/java/com/amperly/app/core/routing/GeoapifyRoutingClient.java

```
47: public final class GeoapifyRoutingClient {
50: public enum TravelMode {
65: public String requestMode() {
70: public boolean isTrafficAware() {
75: public double estimateSpeedKmh() {
79: public String label() {
84: public interface Callback {
85: void onRoute(@NonNull DirectionsRoute route);
87: void onError(@NonNull String message);
103: private GeoapifyRoutingClient() {
110: public static void route(@Nullable Context context, @NonNull TravelMode mode,
147: public static void routeToAddress(@Nullable Context context, @NonNull TravelMode mode,
167: public void onResult(@NonNull PlacesAutocomplete.Selection selection) {
173: public void onError(@NonNull String message) {
181: static DirectionsRoute fetch(@NonNull TravelMode mode, double fromLat, double fromLng,
206: public static DirectionsRoute parseRoute(@NonNull TravelMode mode, @NonNull String json) {
250: private static List<double[]> geometryPoints(@NonNull JsonObject feature) {
275: private static void appendPoints(@NonNull List<double[]> target, @NonNull JsonArray coordinates) {
294: private static boolean samePoint(@NonNull double[] a, @NonNull double[] b) {
302: private static List<DirectionsRoute.Step> steps(@NonNull JsonObject properties,
342: private static String distanceText(double metres) {
350: private static String durationText(double seconds) {
360: static String cacheKey(@NonNull TravelMode mode, double fromLat, double fromLng, double toLat,
367: private static JsonObject object(@NonNull JsonObject parent, @NonNull String key) {
373: private static JsonArray array(@NonNull JsonObject parent, @NonNull String key) {
379: private static String string(@NonNull JsonObject parent, @NonNull String key) {
387: private static double number(@NonNull JsonObject parent, @NonNull String key, double fallback) {
403: private static String describe(@Nullable Context context, Exception e) {
```

## app/src/main/java/com/amperly/app/core/routing/RequestThrottle.java

```
16: public final class RequestThrottle {
25: public RequestThrottle() {
29: public RequestThrottle(int maxPerWindow, long windowMs) {
40: public synchronized long reserveDelayMs(long nowMs) {
53: public synchronized int inWindow(long nowMs) {
58: private void prune(long nowMs) {
```

## app/src/main/java/com/amperly/app/core/routing/RouteCache.java

```
21: public final class RouteCache {
30: private CachedRoute(DirectionsRoute route, long expiresAtMs) {
40: public RouteCache() {
44: public RouteCache(int capacity, long ttlMs) {
49: protected boolean removeEldestEntry(Map.Entry<String, CachedRoute> eldest) {
57: public synchronized DirectionsRoute get(@Nullable String key, long nowMs) {
73: public synchronized void put(@Nullable String key, @Nullable DirectionsRoute route, long nowMs) {
80: public synchronized int size() {
84: public synchronized void clear() {
```

## app/src/main/java/com/amperly/app/core/security/AuthManager.java

```
26: public class AuthManager {
35: private AuthManager() {
40: public static synchronized AuthManager getInstance() {
52: public User getCurrentUser() {
58: public User getAccount() {
62: public void setCurrentUser(@Nullable User user) {
73: public void clearCurrentUser() {
80: public boolean isLoggedIn() {
85: public String getCurrentUserId() {
91: public String getCurrentRole() {
100: public List<String> availableRoles() {
116: public boolean canActAs(String role) {
125: public boolean setRole(@Nullable String role) {
136: public String describeCurrentUser() {
151: public static String authorityLabel(@Nullable User user) {
163: public static String roleLabel(@Nullable String role) {
```

## app/src/main/java/com/amperly/app/core/security/RoleGuard.java

```
12: public class RoleGuard {
15: public static boolean canPerformAdminAction(User user) {
24: public static boolean canManageStation(User user, String stationHostId) {
31: public static boolean canReservePort(User user) {
36: public static boolean canRegisterStation(User user) {
47: public static boolean isRestricted(@Nullable User user, long suspendedUntilMs, long nowMs) {
```

## app/src/main/java/com/amperly/app/core/state/AppStateStore.java

```
21: public final class AppStateStore {
23: public interface Listener {
24: void onStateChanged();
49: private AppStateStore() {
52: public static AppStateStore get() {
54: synchronized (AppStateStore.class) {
63: public void addListener(Listener listener) {
69: public void removeListener(Listener listener) {
73: public void notifyChanged() {
79: public String getUserId() {
83: public void setUserId(String userId) {
87: public String getRole() {
91: public void setRole(String role) {
96: public Vehicle getVehicle() {
100: public void setVehicle(Vehicle vehicle) {
105: public RoutePlan getActivePlan() {
109: public void setActivePlan(RoutePlan activePlan) {
114: public RoutePlannerEngine.RoutePlanResult getLastPlanResult() {
118: public void setLastPlanResult(RoutePlannerEngine.RoutePlanResult lastPlanResult) {
123: public int getEstimatedSoc() {
127: public void setEstimatedSoc(int estimatedSoc) {
132: public int getCurrentSoc() {
147: public void applyStoredSoc(@Nullable String vehicleId, int soc) {
164: public int getAuthoritativeSoc() {
168: public boolean isSocAuthoritative() {
172: public long getSocUpdatedAtMs() {
176: public void applySocCorrection(int previousEstimate, int actualDashboardSoc) {
184: public String getLastRecalculationSummary() {
188: public void setLastRecalculationSummary(String lastRecalculationSummary) {
193: public String getActiveReservationId() {
197: public void setActiveReservation(Reservation reservation) {
202: public void setActiveReservationId(String reservationId) {
207: public String getActiveSessionId() {
211: public void setActiveSessionId(String activeSessionId) {
216: public String getLastBookingCode() {
220: public void setLastBookingCode(String lastBookingCode) {
225: public boolean isCarConnected() {
229: public void setCarConnected(boolean carConnected) {
234: public String getNoSafeChargerMessage() {
238: public void setNoSafeChargerMessage(String noSafeChargerMessage) {
243: public List<ChargerStation> safeReachableStations() {
256: public void reset() {
```

## app/src/main/java/com/amperly/app/core/state/SocStore.java

```
24: public final class SocStore {
33: private SocStore() {
37: public static void save(@Nullable Context context, @Nullable String userId, int soc) {
42: public static void save(@Nullable Context context, @Nullable String userId,
55: public static int load(@Nullable Context context, @Nullable String userId) {
60: public static int load(@Nullable Context context, @Nullable String userId,
88: private static String key(String userId, @Nullable String vehicleId) {
92: private static SharedPreferences prefs(Context context) {
```

## app/src/main/java/com/amperly/app/core/state/TripSessionStore.java

```
27: public final class TripSessionStore {
47: private TripSessionStore() {
70: private TripSession(String userId, String planId, double originLat, double originLng,
91: public String getUserId() {
97: public String getPlanId() {
101: public double getOriginLat() {
105: public double getOriginLng() {
109: public double getDestLat() {
113: public double getDestLng() {
119: public String getLabel() {
124: public int getProgressPercent() {
129: public int getStepIndex() {
133: public double getLastLat() {
137: public double getLastLng() {
142: public boolean hasPosition() {
146: public long getStartedAtMs() {
150: public long getUpdatedAtMs() {
161: public static void start(@Nullable Context context, @Nullable String userId, @Nullable String planId,
197: public static void updatePosition(@Nullable Context context, double latitude, double longitude) {
210: public static void updateProgress(@Nullable Context context, int progressPercent, int stepIndex) {
223: public static TripSession load(@Nullable Context context) {
255: public static boolean hasActive(@Nullable Context context) {
262: public static void end(@Nullable Context context) {
269: private static SharedPreferences prefs(Context context) {
273: private static String value(SharedPreferences prefs, String key) {
278: private static double parseDouble(String value) {
```

## app/src/main/java/com/amperly/app/data/local/AmperlyDatabase.java

```
67: public abstract class AmperlyDatabase extends RoomDatabase {
71: public abstract UserDao userDao();
72: public abstract VehicleDao vehicleDao();
73: public abstract ChargerStationDao chargerStationDao();
74: public abstract ChargerPortDao chargerPortDao();
75: public abstract AvailabilityScheduleDao availabilityScheduleDao();
76: public abstract ReservationDao reservationDao();
77: public abstract ChargingSessionDao chargingSessionDao();
78: public abstract MeterReadingDao meterReadingDao();
79: public abstract InvoiceDao invoiceDao();
80: public abstract PaymentDao paymentDao();
81: public abstract DisputeDao disputeDao();
82: public abstract ReportDao reportDao();
83: public abstract SafetyEventDao safetyEventDao();
84: public abstract TrustedContactDao trustedContactDao();
85: public abstract BatteryUpdateDao batteryUpdateDao();
86: public abstract HostEnforcementActionDao hostEnforcementActionDao();
87: public abstract NotificationDao notificationDao();
88: public abstract ChatMessageDao chatMessageDao();
89: public abstract CommunicationThreadDao communicationThreadDao();
90: public abstract RoutePlanDao routePlanDao();
91: public abstract RouteStopDao routeStopDao();
92: public abstract TripEstimateDao tripEstimateDao();
93: public abstract AndroidAutoSessionDao androidAutoSessionDao();
103: public void migrate(@NonNull SupportSQLiteDatabase db) {
108: public static AmperlyDatabase getInstance(Context context) {
110: synchronized (AmperlyDatabase.class) {
```

## app/src/main/java/com/amperly/app/data/local/dao/AndroidAutoSessionDao.java

```
14: public interface AndroidAutoSessionDao {
16: void insert(AndroidAutoSession session);
19: void update(AndroidAutoSession session);
22: AndroidAutoSession getLatestForUserSync(String userId);
25: List<AndroidAutoSession> getSessionsForUserSync(String userId);
28: List<AndroidAutoSession> getAllSessionsSync();
31: int countSessions();
```

## app/src/main/java/com/amperly/app/data/local/dao/AvailabilityScheduleDao.java

```
15: public interface AvailabilityScheduleDao {
17: void insert(AvailabilitySchedule schedule);
20: void insertAll(List<AvailabilitySchedule> schedules);
23: void update(AvailabilitySchedule schedule);
26: LiveData<List<AvailabilitySchedule>> getSchedulesForStation(String stationId);
29: List<AvailabilitySchedule> getSchedulesForStationSync(String stationId);
32: AvailabilitySchedule getScheduleForPortDaySync(String portId, int dayOfWeek);
35: List<AvailabilitySchedule> getAllSchedulesSync();
38: void deleteForPort(String portId);
42: void deleteForStation(String stationId);
45: void setStationBlocked(String stationId, boolean blocked, String reason, long nowMs);
48: void blockPort(String portId, String reason, long nowMs);
```

## app/src/main/java/com/amperly/app/data/local/dao/BatteryUpdateDao.java

```
13: public interface BatteryUpdateDao {
15: void insert(BatteryUpdate update);
18: List<BatteryUpdate> getUpdatesForTripSync(String planId);
21: BatteryUpdate getLatestForTripSync(String planId);
24: List<BatteryUpdate> getAllUpdatesSync();
31: Integer getFirstEstimateForTrip(String planId);
```

## app/src/main/java/com/amperly/app/data/local/dao/ChargerPortDao.java

```
16: public interface ChargerPortDao {
18: void insert(ChargerPort port);
21: void insertAll(List<ChargerPort> ports);
24: void update(ChargerPort port);
27: void delete(ChargerPort port);
31: void deleteForStation(String stationId);
34: LiveData<List<ChargerPort>> getPortsForStation(String stationId);
37: List<ChargerPort> getPortsForStationSync(String stationId);
40: ChargerPort getPortByIdSync(String id);
43: List<ChargerPort> getAllPortsSync();
46: int countAvailablePorts(String stationId);
```

## app/src/main/java/com/amperly/app/data/local/dao/ChargerStationDao.java

```
16: public interface ChargerStationDao {
18: void insert(ChargerStation station);
21: void insertAll(List<ChargerStation> stations);
24: void update(ChargerStation station);
27: void delete(ChargerStation station);
30: LiveData<List<ChargerStation>> getAllStations();
33: List<ChargerStation> getAllStationsSync();
36: List<ChargerStation> getApprovedStationsSync();
39: LiveData<List<ChargerStation>> getPendingStations();
42: List<ChargerStation> getPendingStationsSync();
45: LiveData<ChargerStation> getStationById(String id);
48: ChargerStation getStationByIdSync(String id);
51: LiveData<List<ChargerStation>> getStationsByHost(String hostId);
54: List<ChargerStation> getStationsByHostSync(String hostId);
57: int countStations();
```

## app/src/main/java/com/amperly/app/data/local/dao/ChargingSessionDao.java

```
15: public interface ChargingSessionDao {
17: void insert(ChargingSession session);
20: void update(ChargingSession session);
23: LiveData<List<ChargingSession>> getSessionsForConsumer(String consumerId);
26: List<ChargingSession> getSessionsForConsumerSync(String consumerId);
29: LiveData<List<ChargingSession>> getSessionsForHost(String hostId);
32: List<ChargingSession> getSessionsForHostSync(String hostId);
35: ChargingSession getSessionByIdSync(String id);
38: ChargingSession getSessionByReservationSync(String reservationId);
41: List<ChargingSession> getSessionsForStationSync(String stationId);
44: List<ChargingSession> getActiveSessionsSync();
47: List<ChargingSession> getAllSessionsSync();
```

## app/src/main/java/com/amperly/app/data/local/dao/ChatMessageDao.java

```
15: public interface ChatMessageDao {
17: void insert(ChatMessage message);
20: void update(ChatMessage message);
23: LiveData<List<ChatMessage>> getMessagesForThread(String threadId);
26: List<ChatMessage> getMessagesForThreadSync(String threadId);
29: List<ChatMessage> getMessagesForReservationSync(String reservationId);
32: List<ChatMessage> getAllMessagesSync();
36: ChatMessage getMessageByIdSync(String id);
39: void markReported(String messageId);
48: void reassignThread(String oldThreadId, String threadId);
51: int purgeExpired(long nowMs);
```

## app/src/main/java/com/amperly/app/data/local/dao/CommunicationThreadDao.java

```
15: public interface CommunicationThreadDao {
17: void insert(CommunicationThread thread);
20: void update(CommunicationThread thread);
23: LiveData<List<CommunicationThread>> getThreadsForConsumer(String consumerId);
26: LiveData<List<CommunicationThread>> getThreadsForHost(String hostId);
29: List<CommunicationThread> getThreadsForHostSync(String hostId);
32: CommunicationThread getThreadByReservationSync(String reservationId);
42: List<CommunicationThread> getThreadsForConsumerAndHostSync(String consumerId, String hostId);
45: void deleteById(String threadId);
48: List<CommunicationThread> getAllThreadsSync();
52: CommunicationThread getThreadByIdSync(String id);
55: void markReported(String threadId);
58: void block(String threadId);
```

## app/src/main/java/com/amperly/app/data/local/dao/DisputeDao.java

```
15: public interface DisputeDao {
17: void insert(Dispute dispute);
20: void update(Dispute dispute);
23: LiveData<List<Dispute>> getAllDisputes();
26: List<Dispute> getAllDisputesSync();
29: LiveData<List<Dispute>> getDisputesForConsumer(String consumerId);
32: List<Dispute> getDisputesForHostSync(String hostId);
35: List<Dispute> getOpenDisputesSync();
38: Dispute getDisputeByIdSync(String id);
41: int countProvenIncidentsForHost(String hostId);
```

## app/src/main/java/com/amperly/app/data/local/dao/HostEnforcementActionDao.java

```
14: public interface HostEnforcementActionDao {
16: void insert(HostEnforcementAction action);
19: LiveData<List<HostEnforcementAction>> getAllActions();
22: List<HostEnforcementAction> getAllActionsSync();
25: List<HostEnforcementAction> getActionsForHostSync(String hostId);
28: List<HostEnforcementAction> getActionsForStationSync(String stationId);
31: int countWarningsAndFines(String hostId);
39: Long activeSuspensionEndsAtMs(String hostId, long nowMs);
42: int countBans(String stationId);
```

## app/src/main/java/com/amperly/app/data/local/dao/InvoiceDao.java

```
15: public interface InvoiceDao {
17: void insert(Invoice invoice);
20: void update(Invoice invoice);
23: Invoice getInvoiceByIdSync(String id);
26: Invoice getInvoiceBySessionSync(String sessionId);
29: LiveData<List<Invoice>> getInvoicesForConsumer(String consumerId);
32: List<Invoice> getInvoicesForConsumerSync(String consumerId);
35: List<Invoice> getInvoicesForHostSync(String hostId);
38: List<Invoice> getAllInvoicesSync();
41: double totalRevenueForHost(String hostId);
44: double totalAdjustmentsForHost(String hostId);
```

## app/src/main/java/com/amperly/app/data/local/dao/MeterReadingDao.java

```
15: public interface MeterReadingDao {
17: void insert(MeterReading reading);
20: void update(MeterReading reading);
23: MeterReading getLatestForSessionSync(String sessionId);
26: LiveData<List<MeterReading>> getReadingsForSession(String sessionId);
29: List<MeterReading> getReadingsForStationSync(String stationId);
32: List<MeterReading> getReadingsForSessionSync(String sessionId);
35: List<MeterReading> getAllReadingsSync();
38: int countForSession(String sessionId);
```

## app/src/main/java/com/amperly/app/data/local/dao/NotificationDao.java

```
15: public interface NotificationDao {
17: void insert(Notification notification);
20: void insertAll(List<Notification> notifications);
23: void update(Notification notification);
26: LiveData<List<Notification>> getNotificationsForUser(String userId);
29: List<Notification> getNotificationsForUserSync(String userId);
32: int countUnread(String userId);
35: void markAllRead(String userId);
```

## app/src/main/java/com/amperly/app/data/local/dao/PaymentDao.java

```
15: public interface PaymentDao {
17: void insert(Payment payment);
20: void update(Payment payment);
23: Payment getPaymentByIdSync(String id);
26: Payment findByIdempotencyKey(String key);
29: Payment getPaymentForReservationSync(String reservationId);
32: Payment getPaymentForSessionSync(String sessionId);
35: LiveData<List<Payment>> getPaymentsForConsumer(String consumerId);
38: List<Payment> getPaymentsForHostSync(String hostId);
41: List<Payment> getAllPaymentsSync();
```

## app/src/main/java/com/amperly/app/data/local/dao/ReportDao.java

```
15: public interface ReportDao {
17: void insert(Report report);
20: void update(Report report);
23: LiveData<List<Report>> getAllReports();
26: List<Report> getAllReportsSync();
29: List<Report> getOpenReportsSync();
32: LiveData<List<Report>> getReportsForReporter(String reporterId);
35: List<Report> getReportsForStationSync(String stationId);
38: int countForStation(String stationId);
```

## app/src/main/java/com/amperly/app/data/local/dao/ReservationDao.java

```
15: public interface ReservationDao {
17: void insert(Reservation reservation);
20: void update(Reservation reservation);
23: LiveData<List<Reservation>> getReservationsForConsumer(String consumerId);
26: List<Reservation> getReservationsForConsumerSync(String consumerId);
29: LiveData<List<Reservation>> getReservationsForStation(String stationId);
32: LiveData<List<Reservation>> getReservationsForHost(String hostId);
35: List<Reservation> getReservationsForHostSync(String hostId);
38: List<Reservation> getReservationsForStationSync(String stationId);
42: List<Reservation> getAllReservationsSync();
45: Reservation getReservationByIdSync(String id);
48: Reservation getReservationByBookingCodeSync(String bookingCode);
51: Reservation getActiveReservationForConsumerSync(String consumerId);
55: List<Reservation> findConflictingReservations(String portId, long startMs, long endMs);
58: int countConflicts(String portId, long startMs, long endMs);
61: List<Reservation> getPendingArrivalsSync(String stationId);
```

## app/src/main/java/com/amperly/app/data/local/dao/RoutePlanDao.java

```
15: public interface RoutePlanDao {
17: void insert(RoutePlan plan);
20: void update(RoutePlan plan);
23: RoutePlan getPlanByIdSync(String id);
26: LiveData<List<RoutePlan>> getPlansForConsumer(String consumerId);
29: List<RoutePlan> getPlansForConsumerSync(String consumerId);
32: RoutePlan getActivePlanSync(String consumerId);
35: List<RoutePlan> getAllPlansSync();
38: int countPlans(String consumerId);
```

## app/src/main/java/com/amperly/app/data/local/dao/RouteStopDao.java

```
15: public interface RouteStopDao {
17: void insert(RouteStop stop);
20: void insertAll(List<RouteStop> stops);
23: void update(RouteStop stop);
26: LiveData<List<RouteStop>> getStopsForPlan(String planId);
29: List<RouteStop> getStopsForPlanSync(String planId);
32: List<RouteStop> getPrimaryStopsSync(String planId);
35: List<RouteStop> getBackupStopsSync(String planId);
38: void deleteStopsForPlan(String planId);
41: void deleteBackupsForPlan(String planId);
```

## app/src/main/java/com/amperly/app/data/local/dao/SafetyEventDao.java

```
15: public interface SafetyEventDao {
17: void insert(SafetyEvent event);
20: void update(SafetyEvent event);
23: LiveData<List<SafetyEvent>> getEventsForConsumer(String consumerId);
26: List<SafetyEvent> getEventsForConsumerSync(String consumerId);
30: SafetyEvent getActiveSharingSync(String consumerId, long nowMs);
33: int expireStaleSharing(long nowMs);
36: List<SafetyEvent> getAllEventsSync();
```

## app/src/main/java/com/amperly/app/data/local/dao/TripEstimateDao.java

```
13: public interface TripEstimateDao {
15: void insert(TripEstimate estimate);
18: List<TripEstimate> getEstimatesForPlanSync(String planId);
21: List<TripEstimate> getEstimatesForVehicleSync(String vehicleId);
24: List<TripEstimate> getAllEstimatesSync();
28: double averageDriftForVehicle(String vehicleId);
```

## app/src/main/java/com/amperly/app/data/local/dao/TrustedContactDao.java

```
15: public interface TrustedContactDao {
17: void insert(TrustedContact contact);
20: void delete(TrustedContact contact);
23: LiveData<List<TrustedContact>> getContactsForUser(String userId);
26: List<TrustedContact> getContactsForUserSync(String userId);
29: List<TrustedContact> getAllContactsSync();
```

## app/src/main/java/com/amperly/app/data/local/dao/UserDao.java

```
15: public interface UserDao {
17: void insert(User user);
20: void insertAll(List<User> users);
23: void update(User user);
26: User getUserByIdSync(String id);
29: LiveData<User> getUserById(String id);
32: LiveData<List<User>> getAllUsers();
35: List<User> getAllUsersSync();
38: User getUserByEmailSync(String email);
41: int countUsers();
```

## app/src/main/java/com/amperly/app/data/local/dao/VehicleDao.java

```
15: public interface VehicleDao {
17: void insert(Vehicle vehicle);
20: void insertAll(List<Vehicle> vehicles);
23: void update(Vehicle vehicle);
33: Vehicle getVehicleByUserIdSync(String userId);
36: LiveData<Vehicle> getVehicleByUserId(String userId);
39: Vehicle getByIdSync(String vehicleId);
42: List<Vehicle> getVehiclesForUserSync(String userId);
45: LiveData<List<Vehicle>> observeVehiclesForUser(String userId);
49: void deactivateOthers(String userId, String keepId);
53: List<String> activeIdsExcept(String userId, String keepId);
56: void markActive(String vehicleId);
59: void deleteById(String vehicleId);
62: int countForUser(String userId);
65: List<Vehicle> getAllVehiclesSync();
```

## app/src/main/java/com/amperly/app/data/local/entity/AndroidAutoSession.java

```
13: public class AndroidAutoSession {
26: public AndroidAutoSession(@NonNull String id, String userId, String vehicleId, String planId,
41: public String getId() { return id; }
44: public String getUserId() { return userId; }
47: public String getVehicleId() { return vehicleId; }
50: public String getPlanId() { return planId; }
53: public String getLastTemplateShown() { return lastTemplateShown; }
56: public int getLastSocUpdatePercent() { return lastSocUpdatePercent; }
59: public long getConnectedAtMs() { return connectedAtMs; }
62: public long getLastSocUpdateAtMs() { return lastSocUpdateAtMs; }
65: public long getDisconnectedAtMs() { return disconnectedAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/AvailabilitySchedule.java

```
13: public class AvailabilitySchedule {
19: private int dayOfWeek; // Calendar.MONDAY..Calendar.SUNDAY (1..7)
26: public AvailabilitySchedule(@NonNull String id, String stationId, String portId, int dayOfWeek,
41: public String getId() { return id; }
44: public String getStationId() { return stationId; }
47: public String getPortId() { return portId; }
50: public int getDayOfWeek() { return dayOfWeek; }
53: public int getOpenMinutes() { return openMinutes; }
56: public int getCloseMinutes() { return closeMinutes; }
59: public boolean isBlocked() { return isBlocked; }
62: public String getBlockReason() { return blockReason; }
65: public long getUpdatedAtMs() { return updatedAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/BatteryUpdate.java

```
8: public class BatteryUpdate {
20: public BatteryUpdate(@NonNull String id, String vehicleId, String tripPlanId,
34: public String getId() { return id; }
37: public String getVehicleId() { return vehicleId; }
40: public String getTripPlanId() { return tripPlanId; }
43: public int getEstimatedSoc() { return estimatedSoc; }
46: public int getActualDashboardSoc() { return actualDashboardSoc; }
49: public double getLatitude() { return latitude; }
52: public double getLongitude() { return longitude; }
55: public long getTimestampMs() { return timestampMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/ChargerPort.java

```
9: public class ChargerPort {
20: public ChargerPort(@NonNull String id, String stationId, String portNumber,
32: public String getId() { return id; }
35: public String getStationId() { return stationId; }
38: public String getPortNumber() { return portNumber; }
41: public String getConnectorType() { return connectorType; }
44: public double getPowerKw() { return powerKw; }
47: public boolean isDc() { return isDc; }
50: public String getStatus() { return status; }
```

## app/src/main/java/com/amperly/app/data/local/entity/ChargerStation.java

```
11: public class ChargerStation {
41: public ChargerStation(@NonNull String id, String hostId, String hostName, String name,
78: public static ChargerStation create(String id, String hostId, String hostName, String name,
96: public String getId() { return id; }
99: public String getHostId() { return hostId; }
102: public String getHostName() { return hostName; }
105: public String getName() { return name; }
108: public String getAddress() { return address; }
111: public double getLatitude() { return latitude; }
114: public double getLongitude() { return longitude; }
117: public String getLocationType() { return locationType; }
120: public String getOperatingHours() { return operatingHours; }
123: public double getPricePerKwh() { return pricePerKwh; }
126: public double getServiceFee() { return serviceFee; }
129: public double getGatewayFee() { return gatewayFee; }
132: public String getVerificationLevel() { return verificationLevel; }
135: public boolean isVerified() { return isVerified; }
138: public boolean isPaused() { return isPaused; }
141: public String getApprovalStatus() { return approvalStatus; }
144: public String getReviewNote() { return reviewNote; }
147: public String getConnectorTypes() { return connectorTypes; }
150: public double getMaxPowerKw() { return maxPowerKw; }
153: public boolean isDcCapable() { return isDcCapable; }
156: public int getPortCount() { return portCount; }
159: public String getAccessRules() { return accessRules; }
162: public double getRating() { return rating; }
165: public double getReliabilityScore() { return reliabilityScore; }
168: public int getIncidentCount() { return incidentCount; }
171: public long getLastUpdatedMs() { return lastUpdatedMs; }
174: public List<String> connectorTypeList() {
182: public boolean supportsPaidEnergyBilling() {
186: public boolean isLiveOnMarketplace() {
```

## app/src/main/java/com/amperly/app/data/local/entity/ChargingSession.java

```
8: public class ChargingSession {
33: public ChargingSession(@NonNull String id, String reservationId, String consumerId, String hostId,
63: public String getId() { return id; }
66: public String getReservationId() { return reservationId; }
69: public String getConsumerId() { return consumerId; }
72: public String getHostId() { return hostId; }
75: public String getStationId() { return stationId; }
78: public String getStationName() { return stationName; }
81: public String getPortId() { return portId; }
84: public long getStartTimeMs() { return startTimeMs; }
87: public long getEndTimeMs() { return endTimeMs; }
90: public double getStartingMeterKwh() { return startingMeterKwh; }
93: public double getEndingMeterKwh() { return endingMeterKwh; }
96: public double getVerifiedKwhConsumed() { return verifiedKwhConsumed; }
99: public double getEnergyCharge() { return energyCharge; }
102: public double getServiceFee() { return serviceFee; }
105: public double getGatewayFee() { return gatewayFee; }
108: public double getTotalPaid() { return totalPaid; }
111: public String getStatus() { return status; }
114: public String getMeterReadingId() { return meterReadingId; }
117: public String getInvoiceId() { return invoiceId; }
120: public boolean isMeterSimulated() { return isMeterSimulated; }
123: public String getVerificationLevel() { return verificationLevel; }
```

## app/src/main/java/com/amperly/app/data/local/entity/ChatMessage.java

```
8: public class ChatMessage {
22: public ChatMessage(@NonNull String id, String threadId, String reservationId,
38: public String getId() { return id; }
41: public String getThreadId() { return threadId; }
44: public String getReservationId() { return reservationId; }
47: public String getSenderId() { return senderId; }
50: public String getReceiverId() { return receiverId; }
53: public String getMessageText() { return messageText; }
56: public long getCreatedAtMs() { return createdAtMs; }
59: public boolean isRead() { return isRead; }
62: public boolean isReported() { return isReported; }
65: public long getExpiresAtMs() { return expiresAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/CommunicationThread.java

```
13: public class CommunicationThread {
30: public CommunicationThread(@NonNull String id, String reservationId, String consumerId,
51: public String getId() { return id; }
54: public String getReservationId() { return reservationId; }
57: public String getConsumerId() { return consumerId; }
60: public String getConsumerName() { return consumerName; }
63: public String getHostId() { return hostId; }
66: public String getHostName() { return hostName; }
69: public String getMaskedConsumerNumber() { return maskedConsumerNumber; }
72: public String getMaskedHostNumber() { return maskedHostNumber; }
75: public boolean isReported() { return isReported; }
78: public boolean isBlocked() { return isBlocked; }
81: public boolean isChatEnabled() { return isChatEnabled; }
84: public long getCreatedAtMs() { return createdAtMs; }
87: public long getExpiresAtMs() { return expiresAtMs; }
90: public boolean isExpired(long nowMs) {
```

## app/src/main/java/com/amperly/app/data/local/entity/Dispute.java

```
8: public class Dispute {
30: public Dispute(@NonNull String id, String sessionId, String consumerId, String consumerName,
56: public String getId() { return id; }
59: public String getSessionId() { return sessionId; }
62: public String getConsumerId() { return consumerId; }
65: public String getConsumerName() { return consumerName; }
68: public String getHostId() { return hostId; }
71: public String getStationId() { return stationId; }
74: public String getStationName() { return stationName; }
77: public String getReason() { return reason; }
80: public String getConsumerNotes() { return consumerNotes; }
83: public String getHostNotes() { return hostNotes; }
86: public String getEvidence() { return evidence; }
89: public String getStatus() { return status; }
92: public String getEnforcementAction() { return enforcementAction; }
95: public double getRefundAmount() { return refundAmount; }
98: public String getResolutionNote() { return resolutionNote; }
101: public boolean isPayoutFrozen() { return isPayoutFrozen; }
104: public long getCreatedAtMs() { return createdAtMs; }
107: public long getResolvedAtMs() { return resolvedAtMs; }
110: public boolean isOpen() {
```

## app/src/main/java/com/amperly/app/data/local/entity/HostEnforcementAction.java

```
16: public class HostEnforcementAction {
30: public HostEnforcementAction(@NonNull String id, String hostId, String stationId,
44: public String getId() { return id; }
47: public String getHostId() { return hostId; }
50: public String getStationId() { return stationId; }
53: public String getActionType() { return actionType; }
56: public String getReason() { return reason; }
59: public double getFineAmount() { return fineAmount; }
62: public long getCreatedAtMs() { return createdAtMs; }
65: public long getExpiresAtMs() { return expiresAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/Invoice.java

```
8: public class Invoice {
27: public Invoice(@NonNull String id, String sessionId, String consumerId, String hostId,
49: public String getId() { return id; }
52: public String getSessionId() { return sessionId; }
55: public String getConsumerId() { return consumerId; }
58: public String getHostId() { return hostId; }
61: public String getStationName() { return stationName; }
64: public double getVerifiedKwh() { return verifiedKwh; }
67: public double getEnergyCharge() { return energyCharge; }
70: public double getServiceFee() { return serviceFee; }
73: public double getGatewayFee() { return gatewayFee; }
76: public double getAdjustment() { return adjustment; }
79: public String getAdjustmentNote() { return adjustmentNote; }
82: public double getFinalTotal() { return finalTotal; }
85: public String getPaymentId() { return paymentId; }
88: public String getStatus() { return status; }
91: public long getIssuedAtMs() { return issuedAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/MeterReading.java

```
8: public class MeterReading {
21: public MeterReading(@NonNull String id, String sessionId, String stationId,
36: public String getId() { return id; }
39: public String getSessionId() { return sessionId; }
42: public String getStationId() { return stationId; }
45: public double getStartMeterKwh() { return startMeterKwh; }
48: public double getEndMeterKwh() { return endMeterKwh; }
51: public String getPhotoEvidenceUri() { return photoEvidenceUri; }
54: public String getVerificationLevel() { return verificationLevel; }
57: public long getTimestampMs() { return timestampMs; }
60: public boolean isSimulated() { return isSimulated; }
```

## app/src/main/java/com/amperly/app/data/local/entity/Notification.java

```
8: public class Notification {
18: public Notification(@NonNull String id, String userId, String title,
29: public String getId() { return id; }
32: public String getUserId() { return userId; }
35: public String getTitle() { return title; }
38: public String getMessage() { return message; }
41: public boolean isRead() { return isRead; }
44: public long getCreatedAtMs() { return createdAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/Payment.java

```
12: public class Payment {
32: public Payment(@NonNull String id, String reservationId, String sessionId, String consumerId,
56: public String getId() { return id; }
59: public String getReservationId() { return reservationId; }
62: public String getSessionId() { return sessionId; }
65: public String getConsumerId() { return consumerId; }
68: public String getHostId() { return hostId; }
71: public String getIdempotencyKey() { return idempotencyKey; }
74: public String getGateway() { return gateway; }
77: public String getGatewayReference() { return gatewayReference; }
80: public double getAuthorizedAmount() { return authorizedAmount; }
83: public double getCapturedAmount() { return capturedAmount; }
86: public double getRefundedAmount() { return refundedAmount; }
89: public double getLateCancellationFee() { return lateCancellationFee; }
92: public String getStatus() { return status; }
95: public String getFailureReason() { return failureReason; }
98: public long getCreatedAtMs() { return createdAtMs; }
101: public long getUpdatedAtMs() { return updatedAtMs; }
104: public boolean isSettled() {
```

## app/src/main/java/com/amperly/app/data/local/entity/Report.java

```
8: public class Report {
22: public Report(@NonNull String id, String reporterId, String reporterName,
38: public String getId() { return id; }
41: public String getReporterId() { return reporterId; }
44: public String getReporterName() { return reporterName; }
47: public String getTargetStationId() { return targetStationId; }
50: public String getTargetHostId() { return targetHostId; }
53: public String getSessionId() { return sessionId; }
56: public String getReportType() { return reportType; }
59: public String getDescription() { return description; }
62: public String getStatus() { return status; }
65: public long getCreatedAtMs() { return createdAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/Reservation.java

```
9: public class Reservation {
32: public Reservation(@NonNull String id, String consumerId, String stationId, String stationName,
59: public String getId() { return id; }
62: public String getConsumerId() { return consumerId; }
65: public String getStationId() { return stationId; }
68: public String getStationName() { return stationName; }
71: public String getPortId() { return portId; }
74: public String getPortLabel() { return portLabel; }
77: public String getBookingCode() { return bookingCode; }
80: public long getStartTimeMs() { return startTimeMs; }
83: public long getEndTimeMs() { return endTimeMs; }
86: public String getStatus() { return status; }
89: public double getPricePerKwh() { return pricePerKwh; }
92: public double getServiceFee() { return serviceFee; }
95: public double getGatewayFee() { return gatewayFee; }
98: public double getCancellationFee() { return cancellationFee; }
101: public boolean isPaid() { return isPaid; }
104: public String getPaymentId() { return paymentId; }
107: public long getCheckedInAtMs() { return checkedInAtMs; }
110: public long getCancelledAtMs() { return cancelledAtMs; }
113: public long getCreatedAtMs() { return createdAtMs; }
117: public boolean isInFreeCancellationWindow(long nowMs) {
121: public boolean isActive() {
```

## app/src/main/java/com/amperly/app/data/local/entity/RoutePlan.java

```
12: public class RoutePlan {
47: public RoutePlan(@NonNull String id, String consumerId, String vehicleId, String origin,
81: public String getId() { return id; }
84: public String getConsumerId() { return consumerId; }
87: public String getVehicleId() { return vehicleId; }
90: public String getOrigin() { return origin; }
93: public String getDestination() { return destination; }
96: public double getOriginLat() { return originLat; }
99: public double getOriginLng() { return originLng; }
102: public double getDestinationLat() { return destinationLat; }
105: public double getDestinationLng() { return destinationLng; }
108: public double getCorridorKm() { return corridorKm; }
111: public String getPreference() { return preference; }
114: public double getTotalDistanceKm() { return totalDistanceKm; }
117: public int getDriveMinutes() { return driveMinutes; }
120: public int getDetourMinutes() { return detourMinutes; }
123: public int getChargingMinutes() { return chargingMinutes; }
126: public int getTotalJourneyMinutes() { return totalJourneyMinutes; }
129: public int getPlannedStartSoc() { return plannedStartSoc; }
132: public int getArrivalSocTarget() { return arrivalSocTarget; }
135: public boolean isSocAuthoritative() { return isSocAuthoritative; }
138: public String getAssumptions() { return assumptions; }
141: public String getConfidence() { return confidence; }
144: public String getStatus() { return status; }
147: public String getRouteProvider() { return routeProvider; }
150: public String getGooglePlaceId() { return googlePlaceId; }
153: public long getCreatedAtMs() { return createdAtMs; }
156: public long getUpdatedAtMs() { return updatedAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/RouteStop.java

```
8: public class RouteStop {
29: public RouteStop(@NonNull String id, String planId, int sequence, String stationId,
54: public String getId() { return id; }
57: public String getPlanId() { return planId; }
60: public int getSequence() { return sequence; }
63: public String getStationId() { return stationId; }
66: public String getStationName() { return stationName; }
69: public boolean isBackup() { return isBackup; }
72: public boolean isReachable() { return isReachable; }
75: public double getDistanceAlongRouteKm() { return distanceAlongRouteKm; }
78: public double getDetourKm() { return detourKm; }
81: public int getDetourMinutes() { return detourMinutes; }
84: public int getArrivalSoc() { return arrivalSoc; }
87: public int getDepartureSoc() { return departureSoc; }
90: public double getEnergyAddedKwh() { return energyAddedKwh; }
93: public int getChargingMinutes() { return chargingMinutes; }
96: public double getEstimatedCost() { return estimatedCost; }
99: public String getRecommendationReason() { return recommendationReason; }
102: public String getReservationId() { return reservationId; }
```

## app/src/main/java/com/amperly/app/data/local/entity/SafetyEvent.java

```
8: public class SafetyEvent {
20: public SafetyEvent(@NonNull String id, String consumerId, String stationId,
34: public String getId() { return id; }
37: public String getConsumerId() { return consumerId; }
40: public String getStationId() { return stationId; }
43: public String getEmergencyType() { return emergencyType; }
46: public boolean isLiveLocationSharingActive() { return isLiveLocationSharingActive; }
49: public String getTrustedContactPhone() { return trustedContactPhone; }
52: public long getExpiresAtMs() { return expiresAtMs; }
55: public long getCreatedAtMs() { return createdAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/TripEstimate.java

```
12: public class TripEstimate {
27: public TripEstimate(@NonNull String id, String planId, String vehicleId, double segmentDistanceKm,
44: public String getId() { return id; }
47: public String getPlanId() { return planId; }
50: public String getVehicleId() { return vehicleId; }
53: public double getSegmentDistanceKm() { return segmentDistanceKm; }
56: public double getEstimatedDrainKwh() { return estimatedDrainKwh; }
59: public double getActualDrainKwh() { return actualDrainKwh; }
62: public int getEstimatedArrivalSoc() { return estimatedArrivalSoc; }
65: public int getActualArrivalSoc() { return actualArrivalSoc; }
68: public String getConfidence() { return confidence; }
71: public String getNotes() { return notes; }
74: public long getCreatedAtMs() { return createdAtMs; }
```

## app/src/main/java/com/amperly/app/data/local/entity/TrustedContact.java

```
8: public class TrustedContact {
16: public TrustedContact(@NonNull String id, String userId, String name, String phone) {
24: public String getId() { return id; }
27: public String getUserId() { return userId; }
30: public String getName() { return name; }
33: public String getPhone() { return phone; }
```

## app/src/main/java/com/amperly/app/data/local/entity/User.java

```
10: public class User {
22: public User(@NonNull String id, String name, String email, String phone, String role,
35: public String getId() { return id; }
38: public String getName() { return name; }
41: public String getEmail() { return email; }
44: public String getPhone() { return phone; }
47: public String getRole() { return role; }
50: public String getOrganizationName() { return organizationName; }
53: public String getVerificationStatus() { return verificationStatus; }
56: public boolean isBlocked() { return isBlocked; }
70: public boolean canActAsConsumer() {
75: public boolean canActAsHost() {
83: public boolean isPlatformAdmin() {
```

## app/src/main/java/com/amperly/app/data/local/entity/Vehicle.java

```
19: public class Vehicle {
41: public Vehicle(@NonNull String id, String userId, String make, String model, String variant,
67: public String getId() { return id; }
70: public String getUserId() { return userId; }
73: public String getMake() { return make; }
76: public String getModel() { return model; }
79: public String getVariant() { return variant; }
82: public int getPurchaseYear() { return purchaseYear; }
85: public double getBatteryCapacityKwh() { return batteryCapacityKwh; }
88: public String getConnectorType() { return connectorType; }
91: public double getMaxAcKw() { return maxAcKw; }
94: public double getMaxDcKw() { return maxDcKw; }
97: public double getTypicalEfficiencyKmPerKwh() { return typicalEfficiencyKmPerKwh; }
100: public double getBatteryHealthPercent() { return batteryHealthPercent; }
103: public double getEfficiencyCorrectionPercent() { return efficiencyCorrectionPercent; }
106: public int getMinArrivalSocPercent() { return minArrivalSocPercent; }
109: public int getMaxChargeSocPercent() { return maxChargeSocPercent; }
112: public String getLicensePlate() { return licensePlate; }
115: public boolean isActive() { return isActive; }
119: public String displayName() {
131: public double effectiveCapacityKwh() {
137: public double effectiveEfficiencyKmPerKwh() {
144: public static double defaultHealthForYear(int purchaseYear) {
```

## app/src/main/java/com/amperly/app/data/remote/SupabaseApi.java

```
27: public final class SupabaseApi {
29: private SupabaseApi() {
40: public interface Postgrest {
86: public interface GoTrue {
93: Call<ResponseBody> signUp(@Body RequestBody body);
96: Call<ResponseBody> logout(@Header("Authorization") String authorization);
```

## app/src/main/java/com/amperly/app/data/remote/SupabaseAuth.java

```
37: public final class SupabaseAuth {
68: private SupabaseAuth() {
73: public Failure(String message) {
80: public NetworkFailure(String message, Throwable cause) {
102: public boolean needsRefresh(long nowMs) {
116: boolean isSuccessful() {
120: JsonObject json() {
135: public static boolean isConfigured() {
140: public static void attach(Context context) {
147: public static boolean isSignedIn() {
152: public static String authUserId() {
158: public static Session signIn(Context context, String email, String password)
186: public static Session signUp(Context context, String email, String password, String name)
217: public static boolean hasStoredSession(Context context) {
231: public static Session restoreSession(Context context) {
260: public static Session refresh(Context context) throws Failure {
283: public static void signOut(Context context) {
304: public static void ensureFreshSession() {
314: public static boolean renewAfterRejection() {
318: private static boolean renewSession(boolean forced) {
323: synchronized (RENEW_LOCK) {
352: private static void apply(Session session) {
357: private static void persist(Context context, Session session) {
367: private static void clear(Context context) {
391: private static SharedPreferences prefs(Context context) {
396: synchronized (PREFS_LOCK) {
429: private static void migrateLegacySession(Context app, SharedPreferences secure) {
453: private static void requireConfigured() throws Failure {
464: private static Session parseSession(HttpResult result, @Nullable String fallbackUserId,
503: private static String describe(HttpResult result, String fallback) {
526: private static String optString(JsonObject json, String key) {
533: private static String firstNonEmpty(String... values) {
542: private static RequestBody toJsonBody(JsonObject json) {
555: private static HttpResult execute(CallSupplier supplier) {
```

## app/src/main/java/com/amperly/app/data/remote/SupabaseClient.java

```
23: public final class SupabaseClient {
34: private SupabaseClient() {
37: static void setAccessToken(@Nullable String token) {
42: static void setAppUserId(@Nullable String userId) {
47: static String appUserId() {
51: public static boolean isReady() {
57: static String authHeader() {
70: private static OkHttpClient httpClient() {
75: synchronized (SupabaseClient.class) {
83: private static OkHttpClient buildHttpClient() {
112: private static Retrofit.Builder retrofitBuilder() {
119: public static SupabaseApi.Postgrest postgrest() {
125: synchronized (SupabaseClient.class) {
134: public static SupabaseApi.GoTrue goTrue() {
140: synchronized (SupabaseClient.class) {
```

## app/src/main/java/com/amperly/app/data/remote/SupabaseConfig.java

```
19: public final class SupabaseConfig {
21: private SupabaseConfig() {
25: public static boolean isConfigured() {
32: public static String baseUrl() {
40: public static String publishableKey() {
45: public static boolean looksLikeSecretKey() {
```

## app/src/main/java/com/amperly/app/data/remote/SupabaseRest.java

```
29: public final class SupabaseRest {
38: private SupabaseRest() {
50: public int getCode() {
59: public boolean isRetryable() {
64: public static boolean isReady() {
90: public boolean isFullPage(int limit) {
95: public static <T> SyncPage<T> selectChanged(String table, Type type, @Nullable String cursor,
134: public static <T> List<T> select(String table, Type type, Map<String, String> query) {
150: public static List<String> selectIds(String table, int limit, int offset) {
185: public static boolean ping() {
203: public static <T> T upsert(String table, Object entity, Type type) {
224: public static void upsertJson(String table, String payloadJson) {
244: public static void updateById(String table, String id, String payloadJson) {
266: public static JsonElement rpc(String function, @Nullable Object args) {
280: public static void deleteById(String table, String id) {
305: private static Response<ResponseBody> call(CallSupplier supplier) {
320: private static void requireSuccess(Response<ResponseBody> response, String body,
329: private static String extractMessage(String body, int code) {
361: static String read(Response<ResponseBody> response) {
373: private static <T> List<T> parseList(String body, Type type) {
```

## app/src/main/java/com/amperly/app/data/remote/SyncEngine.java

```
35: public final class SyncEngine {
47: private SyncEngine() {
66: static Result skipped(String message) {
70: public String summary() {
79: public static boolean isEnabled() {
89: public static void save(String tableName, Object entity) {
106: public static void patch(String tableName, String rowId, Object payload) {
117: public static void delete(String tableName, String rowId) {
129: public static void call(String functionName, @Nullable Object args) {
138: public static Result syncNow(Context context, AmperlyDatabase db) {
174: private static Counts pull(Context context, AmperlyDatabase db) {
216: private static int removeDeletedRows(SyncTables.Table table, AmperlyDatabase db) {
260: private static List<String> localIds(AmperlyDatabase db, String tableName) {
277: public static String statusSummary(Context context, AmperlyDatabase db) {
299: public static void recordWriteError(Context context, @Nullable String message) {
307: public static void reset(Context context) {
311: private static void recordSuccess(Context context) {
318: private static void recordError(Context context, @Nullable String message) {
324: private static SharedPreferences cursors(Context context) {
```

## app/src/main/java/com/amperly/app/data/remote/SyncReconciler.java

```
21: public final class SyncReconciler {
23: private SyncReconciler() {
35: public static List<String> staleIds(@NonNull Collection<String> localIds,
```

## app/src/main/java/com/amperly/app/data/remote/SyncTables.java

```
46: public final class SyncTables {
50: void write(AmperlyDatabase db, Object entity);
64: void write(AmperlyDatabase db, Object entity) {
116: private SyncTables() {
119: private static Table table(String name, Type type, Writer writer) {
124: public static Table byName(String name) {
135: static <T> void write(AmperlyDatabase db, Table table, Object entity) {
140: public static List<String> tableNames() {
```

## app/src/main/java/com/amperly/app/data/repository/AmperlyRepository.java

```
61: public class AmperlyRepository {
65: public interface Callback<T> {
66: void onResult(T value);
89: private AmperlyRepository(Context context) {
94: public static AmperlyRepository getInstance(Context context) {
96: synchronized (AmperlyRepository.class) {
105: public AmperlyDatabase database() {
116: public <T> void background(Callable<T> work, Callback<T> callback) {
132: public void run(Runnable work) {
147: private void pushUpsert(String table, Object entity) {
155: private void pushUpsertAll(String table, List<?> entities) {
164: private void pushDelete(String table, String rowId) {
172: private void pushPatch(String table, String rowId, Object payload) {
184: private void pushRpc(String function, Map<String, Object> args) {
192: private void recordWriteFailure(String action, RuntimeException e) {
198: private static Map<String, Object> singleArg(String key, Object value) {
205: public String syncStatus() {
209: public boolean isBackendEnabled() {
215: public LiveData<User> getUser(String id) {
219: public User getUserSync(String id) {
223: public List<User> getAllUsersSync() {
237: public User findAppUserByAuthId(String authUserId) {
266: public User resolveOrCreateAppUser(String authUserId, String email, String fallbackName) {
307: public boolean didProfileWriteFail() {
327: static Map<String, Object> newUserProfileRow(@NonNull String id, @Nullable String email,
342: private static String displayNameFrom(String email) {
356: public void clearLocalData() {
375: public User updateDisplayName(@Nullable User user, @Nullable String newName) {
403: public LiveData<Vehicle> observeVehicle(String userId) {
408: public LiveData<List<Vehicle>> observeVehicles(String userId) {
418: public Vehicle getVehicleSync(String userId) {
422: public List<Vehicle> getVehiclesSync(String userId) {
433: public void saveVehicle(Vehicle vehicle) {
458: public void setActiveVehicle(Vehicle vehicle) {
471: public void setActiveVehicle(Vehicle vehicle, Callback<List<Vehicle>> callback) {
495: private void setActiveVehicleNow(Vehicle vehicle) {
511: public void deleteVehicle(Vehicle vehicle) {
524: public void deleteVehicle(Vehicle vehicle, Callback<List<Vehicle>> callback) {
552: private void deleteVehicleNow(Vehicle vehicle) {
565: public LiveData<List<ChargerStation>> observeAllStations() {
569: public LiveData<List<ChargerStation>> observePendingStations() {
573: public LiveData<List<ChargerStation>> observeStationsForHost(String hostId) {
577: public LiveData<ChargerStation> observeStation(String stationId) {
581: public List<ChargerStation> getAllStationsSync() {
585: public List<ChargerStation> getApprovedStationsSync() {
589: public List<ChargerStation> getPendingStationsSync() {
593: public List<ChargerStation> getStationsForHostSync(String hostId) {
597: public ChargerStation getStationSync(String stationId) {
601: public void saveStation(ChargerStation station) {
608: public void updateStation(ChargerStation station) {
619: public void updateStationLocally(ChargerStation station) {
623: public void setStationPaused(ChargerStation station, boolean paused) {
643: public String deleteStationConfirmed(ChargerStation station) {
684: public LiveData<List<ChargerPort>> observePorts(String stationId) {
688: public List<ChargerPort> getPortsSync(String stationId) {
692: public List<ChargerPort> getAllPortsSync() {
696: public void savePort(ChargerPort port) {
703: public void savePorts(List<ChargerPort> ports) {
710: public void setPortStatus(ChargerPort port, String status) {
726: public void updatePortStatusLocally(ChargerPort port, String status) {
738: public List<AvailabilitySchedule> getSchedulesSync(String stationId) {
742: public List<AvailabilitySchedule> getAllSchedulesSync() {
746: public void saveSchedules(List<AvailabilitySchedule> schedules) {
753: public void blockStation(String stationId, boolean blocked, String reason) {
763: public void blockPort(String portId, String reason) {
778: public List<AvailabilityEngine.Slot> getSlots(String stationId, long dayStartMs, int slotMinutes,
789: public AvailabilityEngine.AvailabilitySummary getAvailabilitySummary(String stationId) {
809: public Map<String, AvailabilityEngine.AvailabilitySummary> availabilitySummaries(
853: public LiveData<List<Reservation>> observeReservationsForConsumer(String consumerId) {
857: public LiveData<List<Reservation>> observeReservationsForHost(String hostId) {
861: public List<Reservation> getReservationsForConsumerSync(String consumerId) {
865: public List<Reservation> getReservationsForHostSync(String hostId) {
869: public List<Reservation> getReservationsForStationSync(String stationId) {
873: public List<Reservation> getAllReservationsSync() {
877: public Reservation getActiveReservationSync(String consumerId) {
881: public Reservation getReservationSync(String reservationId) {
885: public Reservation getReservationByCodeSync(String bookingCode) {
889: public int countSlotConflicts(String portId, long startMs, long endMs) {
902: private BookingResult(boolean success, String message, @Nullable Reservation reservation,
910: static BookingResult ok(Reservation reservation) {
914: static BookingResult failed(String message) {
930: public BookingResult createReservationConfirmed(String reservationId, String bookingCode,
1010: public String cancelReservationConfirmed(Reservation reservation, double lateFee) {
1039: public void updateReservation(Reservation reservation) {
1048: public LiveData<List<ChargingSession>> observeSessionsForConsumer(String consumerId) {
1052: public LiveData<List<ChargingSession>> observeSessionsForHost(String hostId) {
1056: public List<ChargingSession> getSessionsForConsumerSync(String consumerId) {
1060: public List<ChargingSession> getSessionsForHostSync(String hostId) {
1064: public List<ChargingSession> getAllSessionsSync() {
1068: public ChargingSession getSessionSync(String sessionId) {
1072: public ChargingSession getSessionByReservationSync(String reservationId) {
1076: public void saveSession(ChargingSession session) {
1083: public void updateSession(ChargingSession session) {
1104: public String finalizeSession(ChargingSession session, MeterReading reading, Invoice invoice,
1144: public void decideStationApprovalOnServer(ChargerStation station, boolean approve) {
1155: public void resolveDisputeRefundOnServer(Dispute dispute, Invoice invoice) {
1166: public void freezeDisputePayoutOnServer(Dispute dispute) {
1174: public void applyHostEnforcementOnServer(Dispute dispute, String action, double fineAmount,
1194: public void saveMeterReading(MeterReading reading) {
1207: public MeterReading getLatestMeterReadingSync(String sessionId) {
1211: public List<MeterReading> getMeterReadingsSync(String sessionId) {
1215: public List<MeterReading> getAllMeterReadingsSync() {
1221: public LiveData<List<Invoice>> observeInvoices(String consumerId) {
1230: public void saveInvoice(Invoice invoice) {
1234: public void updateInvoice(Invoice invoice) {
1238: public Invoice getInvoiceSync(String invoiceId) {
1242: public Invoice getInvoiceBySessionSync(String sessionId) {
1246: public List<Invoice> getInvoicesForHostSync(String hostId) {
1250: public List<Invoice> getInvoicesForConsumerSync(String consumerId) {
1254: public List<Invoice> getAllInvoicesSync() {
1267: public void savePayment(Payment payment) {
1272: public void authorizePayment(Payment payment, String stationId) {
1290: public void cancelReservationOnServer(String reservationId) {
1295: public Payment findPaymentByKey(String idempotencyKey) {
1299: public Payment getPaymentForReservationSync(String reservationId) {
1303: public Payment getPaymentForSessionSync(String sessionId) {
1307: public List<Payment> getPaymentsForHostSync(String hostId) {
1313: public LiveData<List<Dispute>> observeDisputes() {
1317: public List<Dispute> getDisputesSync() {
1321: public List<Dispute> getOpenDisputesSync() {
```

## app/src/main/java/com/amperly/app/domain/enums/ChargerStatus.java

```
3: public enum ChargerStatus {
```

## app/src/main/java/com/amperly/app/domain/enums/ConnectorType.java

```
3: public enum ConnectorType {
```

## app/src/main/java/com/amperly/app/domain/enums/MeterVerificationLevel.java

```
3: public enum MeterVerificationLevel {
```

## app/src/main/java/com/amperly/app/domain/enums/ReservationStatus.java

```
3: public enum ReservationStatus {
```

## app/src/main/java/com/amperly/app/domain/enums/UserRole.java

```
3: public enum UserRole {
```

## app/src/main/java/com/amperly/app/engine/admin/EnforcementPolicyEngine.java

```
15: public final class EnforcementPolicyEngine {
35: public EnforcementDecision(String action, String reason, double fineAmount,
48: public String getAction() { return action; }
49: public String getReason() { return reason; }
50: public double getFineAmount() { return fineAmount; }
51: public boolean isSuspendStation() { return suspendStation; }
52: public boolean isBanStation() { return banStation; }
53: public boolean isFreezePayout() { return freezePayout; }
54: public List<String> getAudienceSteps() { return audienceSteps; }
55: public String getHostMessage() { return hostMessage; }
58: private EnforcementPolicyEngine() {
61: public static EnforcementDecision forUnverifiedAccusation() {
76: public static EnforcementDecision decide(int provenIncidentsIncludingThis,
127: public static int suggestedSuspensionDays(int provenIncidentsIncludingThis) {
137: private static List<String> baseSteps() {
```

## app/src/main/java/com/amperly/app/engine/analytics/HostAnalyticsEngine.java

```
21: public final class HostAnalyticsEngine {
39: public HostAnalytics(int sessionsCompleted, double energyDeliveredKwh, double utilizationPercent,
60: public int getSessionsCompleted() { return sessionsCompleted; }
61: public double getEnergyDeliveredKwh() { return energyDeliveredKwh; }
62: public double getUtilizationPercent() { return utilizationPercent; }
63: public double getRevenue() { return revenue; }
64: public double getRefundsAndAdjustments() { return refundsAndAdjustments; }
65: public int getRepeatConsumers() { return repeatConsumers; }
66: public double getCancellationRatePercent() { return cancellationRatePercent; }
67: public double getAverageSessionKwh() { return averageSessionKwh; }
68: public int getDisputes() { return disputes; }
69: public int getOpenDisputes() { return openDisputes; }
70: public int getActiveReservations() { return activeReservations; }
72: public int getReservations() { return reservations; }
73: public int getPorts() { return ports; }
74: public String getUtilizationNote() { return utilizationNote; }
77: private HostAnalyticsEngine() {
80: public static HostAnalytics compute(List<ChargerStation> stations, List<ChargerPort> ports,
162: public static String describe(HostAnalytics analytics) {
169: private static double round2(double value) {
```

## app/src/main/java/com/amperly/app/engine/availability/AvailabilityEngine.java

```
19: public final class AvailabilityEngine {
31: public Slot(String portId, String portLabel, long startMs, long endMs, boolean available,
41: public String getPortId() { return portId; }
42: public String getPortLabel() { return portLabel; }
43: public long getStartMs() { return startMs; }
44: public long getEndMs() { return endMs; }
45: public boolean isAvailable() { return available; }
46: public String getReason() { return reason; }
48: public String label() {
61: public AvailabilitySummary(int totalPorts, int freePorts, long nextFreeSlotMs,
71: public int getTotalPorts() { return totalPorts; }
72: public int getFreePorts() { return freePorts; }
73: public long getNextFreeSlotMs() { return nextFreeSlotMs; }
74: public long getLastUpdatedMs() { return lastUpdatedMs; }
75: public boolean isPaused() { return paused; }
76: public String getLabel() { return label; }
79: private AvailabilityEngine() {
82: public static List<Slot> generateSlots(ChargerStation station, List<ChargerPort> ports,
153: public static AvailabilitySummary summarise(ChargerStation station, List<ChargerPort> ports,
211: public static boolean hasConflict(List<Reservation> reservations, String portId,
230: private static boolean isPortUsable(ChargerPort port) {
234: private static AvailabilitySchedule scheduleFor(List<AvailabilitySchedule> schedules,
250: private static boolean withinWindow(AvailabilitySchedule schedule, long startMs, long endMs) {
262: public static String portLabel(ChargerPort port) {
```

## app/src/main/java/com/amperly/app/engine/billing/BillingEngine.java

```
20: public class BillingEngine {
26: public BillingLine(String label, String value) {
31: public String getLabel() { return label; }
32: public String getValue() { return value; }
51: public BillingCalculationResult(boolean valid, String errorMessage, double startMeterKwh,
72: public boolean isValid() { return valid; }
73: public String getErrorMessage() { return errorMessage; }
74: public double getStartMeterKwh() { return startMeterKwh; }
75: public double getEndMeterKwh() { return endMeterKwh; }
76: public double getVerifiedKwh() { return verifiedKwh; }
77: public double getEnergyCharge() { return energyCharge; }
78: public double getServiceFee() { return serviceFee; }
79: public double getGatewayFee() { return gatewayFee; }
80: public double getAdjustment() { return adjustment; }
81: public double getFinalTotal() { return finalTotal; }
82: public boolean isSimulated() { return simulated; }
83: public boolean isFlaggedForReview() { return flaggedForReview; }
84: public List<BillingLine> getLines() { return lines; }
85: public Invoice getInvoice() { return invoice; }
94: public CancellationResult(boolean free, double fee, double refundAmount, String message) {
101: public boolean isFree() { return free; }
102: public double getFee() { return fee; }
103: public double getRefundAmount() { return refundAmount; }
104: public String getMessage() { return message; }
107: private BillingEngine() {
110: public static BillingCalculationResult calculateBill(String sessionId, String consumerId,
172: public static CancellationResult calculateCancellation(Reservation reservation, long nowMs) {
176: public static CancellationResult calculateCancellation(Reservation reservation, long nowMs,
191: public static Invoice applyRefund(Invoice invoice, double refundAmount, String note) {
209: private static BillingCalculationResult invalid(String message) {
214: public static boolean isVerifiedMeterLevel(String meterLevel) {
219: public static double round2(double value) {
223: public static String money(double amount) {
```

## app/src/main/java/com/amperly/app/engine/booking/ReservationEngine.java

```
16: public final class ReservationEngine {
23: public BookingCheck(boolean allowed, String reason, boolean requiresPaidAuthorization) {
29: public boolean isAllowed() { return allowed; }
30: public String getReason() { return reason; }
31: public boolean isRequiresPaidAuthorization() { return requiresPaidAuthorization; }
42: public PricePreview(double estimatedKwh, double energyCharge, double serviceFee,
52: public double getEstimatedKwh() { return estimatedKwh; }
53: public double getEnergyCharge() { return energyCharge; }
54: public double getServiceFee() { return serviceFee; }
55: public double getGatewayFee() { return gatewayFee; }
56: public double getEstimatedTotal() { return estimatedTotal; }
57: public double getAuthorizedAmount() { return authorizedAmount; }
68: private ReservationEngine() {
71: public static BookingCheck check(ChargerStation station, ChargerPort port, Vehicle vehicle,
123: public static PricePreview preview(ChargerStation station, double estimatedKwh) {
147: public static String buildBookingCode() {
155: public static String bookingQrPayload(Reservation reservation) {
164: private static double round2(double value) {
```

## app/src/main/java/com/amperly/app/engine/meter/MeterSimulator.java

```
13: public final class MeterSimulator {
26: public SimulatedSession(double startReadingKwh, double endReadingKwh, double deliveredKwh,
35: public double getStartReadingKwh() { return startReadingKwh; }
36: public double getEndReadingKwh() { return endReadingKwh; }
37: public double getDeliveredKwh() { return deliveredKwh; }
38: public int getMinutes() { return minutes; }
39: public boolean isSimulated() { return simulated; }
42: private MeterSimulator() {
46: public static synchronized double currentReading(String stationId) {
58: public static synchronized void setReading(String stationId, double reading) {
64: public static synchronized double beginSession(String stationId) {
69: public static synchronized double deliver(String stationId, double powerKw, int minutes) {
76: public static synchronized double endSession(String stationId) {
80: public static synchronized SimulatedSession simulateSession(String stationId, double powerKw,
88: public static synchronized boolean isOffline(String stationId) {
93: public static synchronized void setOffline(String stationId, boolean offline) {
100: public static boolean isValidReading(double startReading, double endReading) {
105: public static boolean isImplausibleReading(double startReading, double endReading,
111: public static double round2(double value) {
```

## app/src/main/java/com/amperly/app/engine/routing/RoutePlannerEngine.java

```
22: public class RoutePlannerEngine {
55: public PlannedStop(ChargerStation station, int sequence, boolean backup, boolean reachable,
74: public String getId() { return id; }
75: public ChargerStation getStation() { return station; }
76: public int getSequence() { return sequence; }
77: public boolean isBackup() { return backup; }
78: public boolean isReachable() { return reachable; }
79: public double getDistanceAlongRouteKm() { return distanceAlongRouteKm; }
80: public double getDetourKm() { return detourKm; }
81: public int getDetourMinutes() { return detourMinutes; }
82: public int getArrivalSoc() { return arrivalSoc; }
83: public int getDepartureSoc() { return departureSoc; }
84: public double getEnergyAddedKwh() { return energyAddedKwh; }
85: public int getChargingMinutes() { return chargingMinutes; }
86: public double getEstimatedCost() { return estimatedCost; }
87: public String getRecommendationReason() { return recommendationReason; }
108: public CandidateEvaluation(ChargerStation station, double distanceFromRouteKm,
131: public ChargerStation getStation() { return station; }
132: public double getDistanceFromRouteKm() { return distanceFromRouteKm; }
133: public double getDistanceAlongRouteKm() { return distanceAlongRouteKm; }
134: public double getDetourKm() { return detourKm; }
135: public int getDetourMinutes() { return detourMinutes; }
136: public int getArrivalSoc() { return arrivalSoc; }
137: public int getDepartureSoc() { return departureSoc; }
138: public int getArrivalAtDestinationSoc() { return arrivalAtDestinationSoc; }
139: public double getEnergyAddedKwh() { return energyAddedKwh; }
140: public int getChargingMinutes() { return chargingMinutes; }
141: public double getEstimatedCost() { return estimatedCost; }
142: public boolean isReachable() { return reachable; }
143: public boolean isPaidBillingAvailable() { return paidBillingAvailable; }
144: public double getScore() { return score; }
145: public String getReason() { return reason; }
153: public ExcludedStation(ChargerStation station, String reason) {
158: public ChargerStation getStation() { return station; }
159: public String getReason() { return reason; }
187: public RoutePlanResult(String origin, String destination, double originLat, double originLng,
221: public String getOrigin() { return origin; }
222: public String getDestination() { return destination; }
223: public double getOriginLat() { return originLat; }
224: public double getOriginLng() { return originLng; }
225: public double getDestinationLat() { return destinationLat; }
226: public double getDestinationLng() { return destinationLng; }
227: public double getTotalDistanceKm() { return totalDistanceKm; }
228: public double getCorridorKm() { return corridorKm; }
229: public int getDriveMinutes() { return driveMinutes; }
230: public int getDetourMinutes() { return detourMinutes; }
231: public int getChargingMinutes() { return chargingMinutes; }
232: public int getTotalJourneyMinutes() { return totalJourneyMinutes; }
233: public int getStartSoc() { return startSoc; }
234: public int getArrivalTargetSoc() { return arrivalTargetSoc; }
235: public String getPreference() { return preference; }
236: public CandidateEvaluation getRecommendedStop() { return recommendedStop; }
237: public List<CandidateEvaluation> getCandidates() { return candidates; }
238: public List<CandidateEvaluation> getCandidateEvaluations() { return candidates; }
239: public List<PlannedStop> getPlannedStops() { return plannedStops; }
240: public List<PlannedStop> getBackups() { return backups; }
241: public List<ExcludedStation> getExcluded() { return excluded; }
242: public List<String> getAssumptions() { return assumptions; }
243: public String getConfidence() { return confidence; }
244: public String getNoStopWarning() { return noStopWarning; }
246: public boolean needsCharging() {
251: private RoutePlannerEngine() {
255: public static RoutePlanResult planRoute(String origin, String destination,
275: public static RoutePlanResult planRoute(String origin, String destination,
443: public static RoutePlanResult planRoute(String origin, String destination, double totalDistanceKm,
449: private static CandidateEvaluation evaluate(ChargerStation station, double distanceFromRoute,
498: private static double score(String preference, int detourMinutes, int chargingMinutes,
522: private static int chargingMinutes(double energyAddedKwh, ChargerStation station, Vehicle vehicle) {
534: private static PlannedStop toPlannedStop(CandidateEvaluation evaluation, int sequence,
547: private static List<PlannedStop> buildBackups(List<CandidateEvaluation> reachableSorted,
578: private static CandidateEvaluation findCandidate(List<CandidateEvaluation> candidates, String stationId) {
587: public static boolean isConnectorCompatible(ChargerStation station, Vehicle vehicle) {
599: public static double drain(double distanceKm, double capacity, double efficiency) {
606: public static int clampSoc(int soc) {
610: private static List<ChargerStation> safeList(List<ChargerStation> stations) {
```

## app/src/main/java/com/amperly/app/engine/routing/TripTimeEngine.java

```
3: public class TripTimeEngine {
11: public TripTimeBreakdown(int drivingMinutes, int detourMinutes, int chargingMinutes) {
18: public int getDrivingMinutes() { return drivingMinutes; }
19: public int getDetourMinutes() { return detourMinutes; }
20: public int getChargingMinutes() { return chargingMinutes; }
21: public int getTotalJourneyMinutes() { return totalJourneyMinutes; }
24: public static TripTimeBreakdown calculateBreakdown(double distanceKm, int detourMinutes, int chargingMinutes) {
```

## app/src/main/java/com/amperly/app/engine/soc/SoCEstimatorEngine.java

```
25: public class SoCEstimatorEngine {
34: public SocEstimate(int soc, boolean fromProfile, String source) {
40: public int getSoc() { return soc; }
41: public boolean isFromProfile() { return fromProfile; }
42: public String getSource() { return source; }
57: public RemainingStop(ChargerStation station, double distanceFromCurrentKm, double detourKm,
72: public ChargerStation getStation() { return station; }
73: public double getDistanceFromCurrentKm() { return distanceFromCurrentKm; }
74: public double getDetourKm() { return detourKm; }
75: public int getDetourMinutes() { return detourMinutes; }
76: public int getArrivalSoc() { return arrivalSoc; }
77: public int getDepartureSoc() { return departureSoc; }
78: public int getChargingMinutes() { return chargingMinutes; }
79: public double getEnergyAddedKwh() { return energyAddedKwh; }
80: public boolean isReachable() { return reachable; }
81: public String getNote() { return note; }
109: public RecalculationResult(int previousEstimatedSoc, int actualDashboardSoc,
146: public int getPreviousEstimatedSoc() { return previousEstimatedSoc; }
147: public int getActualDashboardSoc() { return actualDashboardSoc; }
148: public boolean isWasOverrideApplied() { return wasOverrideApplied; }
149: public double getCurrentLat() { return currentLat; }
150: public double getCurrentLng() { return currentLng; }
151: public double getRemainingDistanceKm() { return remainingDistanceKm; }
152: public List<ChargerStation> getSafeReachableStations() { return safeReachableStations; }
153: public List<ChargerStation> getUnreachableStations() { return unreachableStations; }
154: public List<ChargerStation> getNewlyReachableStations() { return newlyReachableStations; }
155: public ChargerStation getRecommendedNextCharger() { return recommendedNextCharger; }
156: public RemainingStop getRecommendedStop() { return recommendedStop; }
157: public List<RemainingStop> getRemainingOptions() { return remainingOptions; }
158: public int getEstimatedRangeKm() { return estimatedRangeKm; }
159: public int getRemainingDriveMinutes() { return remainingDriveMinutes; }
160: public int getRemainingChargingMinutes() { return remainingChargingMinutes; }
161: public int getRemainingJourneyMinutes() { return remainingJourneyMinutes; }
162: public boolean isNoSafeCharger() { return noSafeCharger; }
163: public String getWarningMessage() { return warningMessage; }
164: public String getExplanation() { return explanation; }
165: public String getReservationAdvice() { return reservationAdvice; }
166: public boolean isNeedsWiderRadius() { return needsWiderRadius; }
167: public BatteryUpdate getAuditRecord() { return auditRecord; }
170: private SoCEstimatorEngine() {
173: public static int estimateSocAfterDistance(int startSoc, double distanceKm, Vehicle vehicle) {
181: private static double RoutePlannerEngineDrain(double distanceKm, Vehicle vehicle) {
192: public static SocEstimate estimateStartingSoc(Vehicle vehicle, double typicalDailyDistanceKm) {
211: public static RecalculationResult applyAuthoritativeSocOverride(
226: public static RecalculationResult applyAuthoritativeSocOverride(
356: public static List<ChargerStation> safeAlternatives(List<ChargerStation> stations, int soc,
383: private static boolean previousListContains(List<ChargerStation> stations, String id) {
395: private static int countOf(List<ChargerStation> stations) {
399: private static List<ChargerStation> safeList(List<ChargerStation> stations) {
405: static boolean isCompatible(ChargerStation station, Vehicle vehicle) {
```

## app/src/main/java/com/amperly/app/feature/admin/AdminDashboardFragment.java

```
48: public class AdminDashboardFragment extends Fragment {
69: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
75: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
85: public void onApprove(ChargerStation station) {
90: public void onReject(ChargerStation station) {
101: public void onRefund(Dispute dispute) {
106: public void onFreezePayout(Dispute dispute) {
117: public void onWarning(Dispute dispute) {
122: public void onFine(Dispute dispute) {
128: public void onSuspend(Dispute dispute) {
133: public void onBan(Dispute dispute) {
141: public void onWarning(Report report) {
146: public void onSuspend(Report report) {
151: public void onBan(Report report) {
176: private boolean isQueueSection() {
187: private void applySection(@NonNull String section) {
210: private void show(int viewId, boolean visible) {
218: private void load() {
278: private boolean canActAsAdmin() {
286: private void decideStation(ChargerStation station, boolean approve) {
318: private void resolveWithRefund(Dispute dispute) {
331: private void performRefund(Dispute dispute) {
363: private void confirmEnforcement(Dispute dispute, String action, double fineAmount) {
396: private void applyEnforcement(Dispute dispute, String action, double fineAmount) {
454: private boolean isHostReport(@NonNull Report report) {
474: private String reporterName(Report report) {
483: private String reportedName(Report report) {
498: private String displayName(@Nullable String userId) {
510: private void chooseSuspension(Report report) {
546: private String suspensionLabel(int days) {
557: private void confirmReportBan(Report report) {
578: private void applyReportAction(Report report, String action, long expiresAtMs) {
601: private String actionLabel(String action) {
```

## app/src/main/java/com/amperly/app/feature/auth/AccountFragment.java

```
49: public class AccountFragment extends Fragment {
72: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
78: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
147: public void onResume() {
154: public void onHiddenChanged(boolean hidden) {
161: private void refreshAccount() {
171: private void renderRoleChips() {
198: private void loadSyncStatus() {
208: private void render(@Nullable User user, boolean signedIn) {
243: private void addRow(String label, @Nullable String value) {
269: private String displayNameOf(@Nullable User user) {
282: private static String initialsOf(@Nullable String name) {
309: private void showEditNameDialog() {
349: private void saveName(@NonNull String name) {
374: private void confirmSignOut() {
390: private void signOut() {
```

## app/src/main/java/com/amperly/app/feature/auth/SignInFragment.java

```
43: public class SignInFragment extends Fragment {
65: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
71: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
117: public void onResume() {
122: private boolean serverConfigured() {
128: private void submit(boolean createAccount) {
167: private Outcome attempt(Context appContext, String name, String email, String password,
214: private void handle(@Nullable Outcome outcome) {
242: private void setBusy(boolean busy, boolean createAccount) {
266: private void setCreateMode(boolean enabled) {
280: private void hideMessages() {
285: private android.text.TextWatcher clearErrorOnEdit(final TextInputLayout field) {
288: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
292: public void onTextChanged(CharSequence s, int start, int before, int count) {
296: public void afterTextChanged(android.text.Editable s) {
304: private void showError(String message) {
310: private void showInfo(String message) {
324: private Outcome(@Nullable User user, @Nullable String message, boolean info) {
330: static Outcome signedIn(User user) {
334: static Outcome failed(String message) {
338: static Outcome notice(String message) {
342: boolean isSuccess() {
```

## app/src/main/java/com/amperly/app/feature/common/NotificationsFragment.java

```
26: public class NotificationsFragment extends Fragment {
33: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
39: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
54: private void render(List<Notification> notifications) {
```

## app/src/main/java/com/amperly/app/feature/consumer/ActiveSessionFragment.java

```
41: public class ActiveSessionFragment extends Fragment {
67: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
73: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
122: private void loadState(String reservationId) {
147: private void renderState() {
200: private void checkIn(String reservationId) {
248: private void markCharging(String reservationId) {
265: private void simulateMeter() {
280: private void completeSession(String reservationId) {
```

## app/src/main/java/com/amperly/app/feature/consumer/BookingQrFragment.java

```
36: public class BookingQrFragment extends Fragment {
44: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
50: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
116: private Bitmap renderQr(String payload) {
```

## app/src/main/java/com/amperly/app/feature/consumer/ChargerDetailsFragment.java

```
45: public class ChargerDetailsFragment extends Fragment {
83: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
89: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
108: private void bind(View view, ChargerStation station) {
209: public void onLocationRetrieved(double latitude, double longitude) {
219: public void onLocationUnavailable() {
243: private void openNavigation(double fromLat, double fromLng, ChargerStation station) {
262: private void renderTimeline(View root, String stationId) {
335: private String summariseSchedule(int[] free, int[] total, int slotMinutes) {
369: private void setUpDirections(View view) {
391: private void ensureUserLocation() {
408: private void resolveUserLocation() {
412: public void onLocationRetrieved(double latitude, double longitude) {
419: public void onLocationUnavailable() {
428: private void requestRoute() {
447: public void onRoute(DirectionsRoute route) {
454: public void onError(String message) {
468: private void renderRoute(DirectionsRoute route) {
488: private String verificationLabel(ChargerStation station) {
```

## app/src/main/java/com/amperly/app/feature/consumer/ChargerDiscoveryFragment.java

```
54: public class ChargerDiscoveryFragment extends Fragment implements StationAdapter.Listener {
108: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
114: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
181: public void onResume() {
193: public void onHiddenChanged(boolean hidden) {
200: private void loadStations() {
337: private void showVehicleSwitcher() {
341: public void onVehicleSwitched(@NonNull Vehicle switched) {
346: public void onManageVehicles() {
354: private void applyVehicleSwitch(Vehicle chosen) {
374: private void updateSwitcherContentDescription() {
383: private static Double distanceFrom(@Nullable Double fromLat, @Nullable Double fromLng,
392: private void plotMap() {
399: private void promptForBattery() {
414: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
418: public void onTextChanged(CharSequence s, int start, int before, int count) {
422: public void afterTextChanged(Editable s) {
456: private int parseInt(String value) {
464: private void saveBattery(int soc) {
474: private void applyFilter() {
522: private String filterLabel() {
540: private void showAll() {
550: private void ensureUserLocation() {
565: private void resolveUserLocation() {
569: public void onLocationRetrieved(double latitude, double longitude) {
584: public void onLocationUnavailable() {
596: private void applyDistances() {
613: public void onSelectStation(ChargerStation station) {
622: public void onOpenStation(ChargerStation station) {
631: public void onNavigateToStation(ChargerStation station) {
646: public void onLocationRetrieved(double latitude, double longitude) {
658: public void onLocationUnavailable() {
668: private void openNavigation(double fromLat, double fromLng, ChargerStation station) {
```

## app/src/main/java/com/amperly/app/feature/consumer/HostChatFragment.java

```
42: public class HostChatFragment extends Fragment {
63: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
69: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
148: private void scrollToLatest() {
158: private void bindThreads(List<CommunicationThread> threads) {
185: private CommunicationThread preferredThread(List<CommunicationThread> threads) {
196: private void selectThread(CommunicationThread thread) {
218: private void sendMessage() {
```

## app/src/main/java/com/amperly/app/feature/consumer/InAppNavigationFragment.java

```
59: public class InAppNavigationFragment extends Fragment {
83: public void run() {
115: public static InAppNavigationFragment forActiveTrip(@NonNull Context context) {
135: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
141: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
191: private void startNavigation() {
201: public void onRoute(@NonNull NavigationProvider.RouteResult result) {
211: public void onStarted(@NonNull NavigationState state) {
232: public void onRerouted(@NonNull NavigationState state) {
238: public void onArrived(@NonNull NavigationState state) {
243: public void onStopped() {
247: public void onError(@NonNull String message) {
254: public void onError(@NonNull String message) {
263: private void scheduleProgress() {
274: private void rememberTrip() {
281: private void refreshProgress() {
291: public void onLocationRetrieved(double latitude, double longitude) {
300: private void plotNavigation() {
308: private void applyPosition(double latitude, double longitude) {
337: private void render(@Nullable NavigationState state) {
367: private String arrivalClock(int remainingMinutes) {
373: private void arriving() {
383: private void promptBatteryUpdate() {
390: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
394: public void onTextChanged(CharSequence s, int start, int before, int count) {
398: public void afterTextChanged(Editable s) {
439: private void recalculateFromPosition() {
446: public void onLocationRetrieved(double latitude, double longitude) {
458: public void onRoute(@NonNull NavigationProvider.RouteResult result) {
472: public void onError(@NonNull String message) {
480: private void stopNavigation() {
495: private void leaveNavigationScreen() {
507: private void showStatus(String message) {
512: private int parseInt(String value) {
521: public void onResume() {
531: public void onHiddenChanged(boolean hidden) {
544: public void onPause() {
```

## app/src/main/java/com/amperly/app/feature/consumer/ReceiptFragment.java

```
38: public class ReceiptFragment extends Fragment {
48: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
54: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
90: private String portLabel(@Nullable Reservation reservation, @Nullable ChargingSession session) {
100: private void render(View view, ReceiptData data) {
209: private double tariffOf(@Nullable Reservation reservation, @Nullable ChargingSession session) {
219: private void addLine(String label, String value) {
```

## app/src/main/java/com/amperly/app/feature/consumer/ReservationFragment.java

```
53: public class ReservationFragment extends Fragment implements ReservationAdapter.Listener {
77: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
83: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
162: private void loadBookingForm(View view, String userId) {
217: public void onResume() {
224: public void onHiddenChanged(boolean hidden) {
231: private void refreshActiveVehicle() {
241: private void applyVehicle(@Nullable Vehicle vehicle) {
261: private void showVehicleSwitcher() {
266: public void onVehicleSwitched(@NonNull Vehicle vehicle) {
276: public void onManageVehicles() {
284: private void bindPortDropdown(List<String> labels) {
302: private void loadSlots(ChargerPort port) {
344: private void updatePricePreview(ChargerPort port) {
372: private void authorizeBooking(String userId) {
439: public void onOpenQr(Reservation reservation) {
448: public void onCheckIn(Reservation reservation) {
458: public void onMessageHost(Reservation reservation) {
470: public void onCancel(Reservation reservation) {
491: private void showStatus(String message) {
500: private void performCancel(Reservation reservation) {
```

## app/src/main/java/com/amperly/app/feature/consumer/RoutePlannerFragment.java

```
72: public class RoutePlannerFragment extends Fragment implements RouteStopAdapter.Listener {
138: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
144: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
201: public void onResume() {
213: public void onHiddenChanged(boolean hidden) {
220: private void loadActiveVehicle() {
248: private void applyVehicle(@Nullable Vehicle vehicle) {
259: private void applyBatteryForVehicle(@Nullable Vehicle vehicle) {
267: private void updateVehicleRowDescription() {
278: private void showVehicleSwitcher() {
283: public void onVehicleSwitched(@NonNull Vehicle vehicle) {
300: public void onManageVehicles() {
307: private void setUpChips(View view) {
345: private void setUpInputs(View view) {
380: public void onPlaceSelected(@NonNull PlacesAutocomplete.Selection selection) {
389: public void onSelectionCleared() {
396: public void onLookupFailed(@NonNull String message) {
408: private void attachMap() {
430: private void resolveOrigin() {
451: public void onLocationRetrieved(double latitude, double longitude) {
463: public void onLocationUnavailable() {
478: private void describeOrigin(double latitude, double longitude) {
488: public void onAddress(@NonNull String formattedAddress) {
496: public void onError(@NonNull String message) {
505: private void showOriginUnavailable() {
518: private void planRoute() {
541: public void onRoute(@NonNull NavigationProvider.RouteResult result) {
550: public void onError(@NonNull String message) {
568: private void runPlan(@NonNull NavigationProvider.RouteResult routeResult) {
638: private void renderPlan(@NonNull PlanBundle bundle) {
713: private void renderDirections(@NonNull DirectionsRoute route) {
747: private void startInAppNavigation() {
784: private List<ChargerStation> stationsOf(RoutePlannerEngine.RoutePlanResult result) {
792: private void applySocCorrection(int reserveOverridePercent) {
850: private void renderRecalculation(SoCEstimatorEngine.RecalculationResult result, int previousEstimate) {
906: private void replanWithNewSoc(int soc) {
919: private void setupList(RecyclerView recyclerView, RouteStopAdapter adapter) {
925: private void showStatus(String message) {
937: private void revealPlanStatus() {
946: private void addLine(LinearLayout container, String text) {
955: private void showEmergencyGuidance() {
966: public void onReserveStop(String stationId, String stationName) {
974: private List<RouteStop> toStops(String planId, RoutePlannerEngine.RoutePlanResult result) {
986: private RouteStop stop(String planId, int sequence, RoutePlannerEngine.PlannedStop stop,
995: private String join(List<String> values) {
1006: private int safeInt(String value) {
1023: private void renderPlanVehicle(@Nullable Vehicle plannedFor) {
```

## app/src/main/java/com/amperly/app/feature/consumer/SafetySOSFragment.java

```
36: public class SafetySOSFragment extends Fragment implements ContactAdapter.Listener {
52: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
58: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
101: private void clearErrorsWhileEditing(View view) {
104: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
108: public void onTextChanged(CharSequence s, int start, int before, int count) {
112: public void afterTextChanged(Editable s) {
132: public void onResume() {
138: private void loadState() {
167: private void updateSharingStatus() {
178: private void triggerSos() {
194: private void startSharing() {
216: private void stopSharing() {
234: private void addContact(View view) {
266: public void onCall(TrustedContact contact) {
271: public void onDelete(TrustedContact contact) {
```

## app/src/main/java/com/amperly/app/feature/consumer/VehicleFormFragment.java

```
43: public class VehicleFormFragment extends Fragment {
82: public static VehicleFormFragment newInstance(@Nullable String vehicleId) {
92: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
98: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
143: private void loadVehicle(@NonNull String vehicleId) {
163: private void startNewVehicle() {
174: private void fillForm(Vehicle loaded) {
192: private void clearForm() {
212: private void guardBackWhileEditing() {
216: public void handleOnBackPressed() {
237: private boolean hasUnsavedChanges() {
242: private String snapshot() {
252: private int indexOf(String connector) {
262: private void clearErrorsWhileEditing() {
267: private TextWatcher clearOnEdit(final TextInputLayout field) {
270: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
274: public void onTextChanged(CharSequence s, int start, int before, int count) {
278: public void afterTextChanged(Editable s) {
286: private void buildDerivedPreview() {
299: private String deriveText() {
312: private void updateDerived(Vehicle loaded) {
320: private void save() {
359: private void close() {
367: private void confirmDelete() {
379: private void delete() {
394: private static Vehicle activeOf(List<Vehicle> vehicles) {
403: private int safeInt(String value, int fallback) {
411: private double parseDouble(String value, double fallback) {
```

## app/src/main/java/com/amperly/app/feature/consumer/VehicleProfileFragment.java

```
35: public class VehicleProfileFragment extends Fragment implements VehicleCardAdapter.Listener {
45: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
51: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
81: private void renderEmpty() {
88: private void openForm(@Nullable String vehicleId) {
93: public void onEdit(Vehicle vehicle) {
98: public void onUse(Vehicle vehicle) {
```

## app/src/main/java/com/amperly/app/feature/host/HostBookingsFragment.java

```
37: public class HostBookingsFragment extends Fragment {
46: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
52: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
60: public void onShowCode(Reservation reservation) {
69: public void onChat(Reservation reservation) {
80: public void onReceipt(Reservation reservation) {
97: public void onResume() {
104: private void load() {
```

## app/src/main/java/com/amperly/app/feature/host/HostDashboardFragment.java

```
41: public class HostDashboardFragment extends Fragment {
49: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
55: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
73: public void onViewReceipt(ChargingSession session) {
80: public void onReportSession(ChargingSession session) {
91: private void load(SessionAdapter sessionAdapter) {
109: private void bindStats(HostAnalyticsEngine.HostAnalytics analytics) {
126: private void bindAnalytics(HostAnalyticsEngine.HostAnalytics analytics) {
150: private void addRow(String label, String value) {
158: private boolean canManage(ChargerStation station) {
168: private void chooseStationToDelete() {
192: private void confirmDelete(ChargerStation station) {
204: private void deleteStation(ChargerStation station) {
```

## app/src/main/java/com/amperly/app/feature/host/HostStationsFragment.java

```
39: public class HostStationsFragment extends Fragment implements StationCardAdapter.Listener {
48: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
54: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
83: private void renderEmpty() {
90: private boolean canManage(ChargerStation station) {
100: public void onTogglePause(ChargerStation station) {
114: public void onEvidence(ChargerStation station) {
```

## app/src/main/java/com/amperly/app/feature/host/RegisterStationFragment.java

```
55: public class RegisterStationFragment extends Fragment {
100: public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
106: public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
168: private void guardBackWhileEditing() {
172: public void handleOnBackPressed() {
193: private boolean hasUnsavedChanges() {
199: private String snapshot(View view) {
214: private void clearErrorsWhileEditing() {
217: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
221: public void onTextChanged(CharSequence s, int start, int before, int count) {
225: public void afterTextChanged(Editable s) {
238: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
242: public void onTextChanged(CharSequence s, int start, int before, int count) {
246: public void afterTextChanged(Editable s) {
259: private void setUpLocationPicker(View view) {
270: public void beforeTextChanged(CharSequence s, int start, int count, int after) {
274: public void onTextChanged(CharSequence s, int start, int before, int count) {
278: public void afterTextChanged(Editable s) {
305: public void onPlaceSelected(@NonNull PlacesAutocomplete.Selection selection) {
311: public void onSelectionCleared() {
323: private void onMapPointPicked(double latitude, double longitude) {
328: public void onAddress(@NonNull String formattedAddress) {
336: public void onError(@NonNull String message) {
347: private void pinAutoLocationBaseline() {
365: private void autoDetectLocation() {
381: private void useCurrentLocation() {
392: public void onLocationRetrieved(double latitude, double longitude) {
397: public void onLocationUnavailable() {
410: public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
426: private void applyPicked(double latitude, double longitude) {
439: private void save(View view) {
533: private String text(View view, int id) {
538: private static String pick(String[] values, int index) {
543: private static String[] connectorLabels() {
551: private double parse(String value, double fallback) {
```

## app/src/main/java/com/amperly/app/payment/PaymentManager.java

```
17: public class PaymentManager {
24: public PaymentResult(boolean success, Payment payment, String message) {
30: public boolean isSuccess() { return success; }
31: public Payment getPayment() { return payment; }
35: public String getMessage() { return message; }
48: public static void setGatewayAvailable(boolean available) {
52: public static boolean isGatewayAvailable() {
56: public static synchronized void resetIdempotencyCache() {
68: public static synchronized PaymentResult authorize(String consumerId, String hostId,
101: public static PaymentResult capture(Payment payment, String sessionId, double verifiedAmount) {
119: public static PaymentResult refund(Payment payment, double amount, String reason) {
137: public static PaymentResult release(Payment payment, double lateCancellationFee) {
153: public static String newIdempotencyKey(String consumerId, String stationId, long slotStartMs) {
157: private static double round2(double value) {
161: private static String format(double amount) {
```

## app/src/main/java/com/amperly/app/ui/Ux.java

```
33: public final class Ux {
42: private Ux() {
45: public static void toast(@Nullable Fragment fragment, String message) {
49: public static void toast(@Nullable Context context, String message) {
53: public static void snack(@Nullable View anchor, String message) {
57: public static void info(@Nullable Fragment fragment, String message) {
61: public static void info(@Nullable Context context, String message) {
65: public static void success(@Nullable Fragment fragment, String message) {
69: public static void success(@Nullable View view, String message) {
73: public static void success(@Nullable Context context, String message) {
77: public static void error(@Nullable Fragment fragment, String message) {
81: public static void error(@Nullable Context context, String message) {
85: public static void error(@Nullable View view, String message) {
93: private static void show(@Nullable View view, @Nullable String message, Tone tone) {
114: private static void applyTone(Snackbar bar, Context context, Tone tone) {
129: private static View bottomNavigationAnchor(@Nullable View view) {
143: private static View contentView(@Nullable Context context) {
150: public static String formatMoney(double amount) {
163: public static void keepFieldsVisible(@Nullable View root) {
181: public static void keepVisibleOnFocus(@Nullable View field) {
189: public static void keepVisibleOnFocus(@Nullable View field,
208: public static void resizeForKeyboard(@Nullable android.app.Dialog dialog) {
223: public static void scrollIntoView(@Nullable View field) {
231: private static void scrollIntoViewNow(View field) {
256: private static void smoothScrollBy(View scroller, int dy) {
271: private static ViewGroup scrollingAncestor(View view) {
282: private static int dp(@Nullable Context context, int value) {
```

## app/src/main/java/com/amperly/app/ui/adapter/ChatMessageAdapter.java

```
21: public class ChatMessageAdapter extends RecyclerView.Adapter<ChatMessageAdapter.MessageViewHolder> {
26: public ChatMessageAdapter(String currentUserId) {
30: public void submit(List<ChatMessage> messages) {
38: public int getItemCountSafe() {
44: public MessageViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
51: public void onBindViewHolder(@NonNull MessageViewHolder holder, int position) {
56: public int getItemCount() {
60: class MessageViewHolder extends RecyclerView.ViewHolder {
76: void bind(ChatMessage message) {
```

## app/src/main/java/com/amperly/app/ui/adapter/ContactAdapter.java

```
18: public class ContactAdapter extends RecyclerView.Adapter<ContactAdapter.ContactViewHolder> {
20: public interface Listener {
21: void onCall(TrustedContact contact);
22: void onDelete(TrustedContact contact);
28: public ContactAdapter(Listener listener) {
32: public void submit(List<TrustedContact> contacts) {
42: public ContactViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
49: public void onBindViewHolder(@NonNull ContactViewHolder holder, int position) {
54: public int getItemCount() {
58: class ContactViewHolder extends RecyclerView.ViewHolder {
72: void bind(TrustedContact contact) {
```

## app/src/main/java/com/amperly/app/ui/adapter/DisputeAdapter.java

```
23: public class DisputeAdapter extends RecyclerView.Adapter<DisputeAdapter.DisputeViewHolder> {
25: public interface Listener {
26: void onRefund(Dispute dispute);
27: void onFreezePayout(Dispute dispute);
28: void onWarning(Dispute dispute);
29: void onFine(Dispute dispute);
30: void onSuspend(Dispute dispute);
31: void onBan(Dispute dispute);
38: public DisputeRow(Dispute dispute, List<MeterReading> evidence) {
43: public Dispute getDispute() { return dispute; }
49: public DisputeAdapter(Listener listener) {
53: public void submit(List<DisputeRow> rows) {
63: public DisputeViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
70: public void onBindViewHolder(@NonNull DisputeViewHolder holder, int position) {
75: public int getItemCount() {
79: class DisputeViewHolder extends RecyclerView.ViewHolder {
109: void bind(DisputeRow row) {
168: private void setEnabledIfOpen(MaterialButton button, boolean open) {
173: private void notifyListener(int which, Dispute dispute) {
187: private String fmt(double value) {
```

## app/src/main/java/com/amperly/app/ui/adapter/HostBookingCardAdapter.java

```
29: public class HostBookingCardAdapter extends RecyclerView.Adapter<HostBookingCardAdapter.BookingViewHolder> {
31: public interface Listener {
32: void onShowCode(Reservation reservation);
34: void onChat(Reservation reservation);
36: void onReceipt(Reservation reservation);
44: public Item(@NonNull Reservation reservation, @Nullable String consumerName) {
50: public Reservation getReservation() {
55: public String getConsumerName() {
63: public HostBookingCardAdapter(Listener listener) {
67: public void submit(@Nullable List<Item> bookings) {
77: public BookingViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
84: public void onBindViewHolder(@NonNull BookingViewHolder holder, int position) {
89: public int getItemCount() {
93: class BookingViewHolder extends RecyclerView.ViewHolder {
113: void bind(Item item) {
```

## app/src/main/java/com/amperly/app/ui/adapter/NotificationAdapter.java

```
19: public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.RowViewHolder> {
23: public void submit(List<Notification> notifications) {
33: public RowViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
40: public void onBindViewHolder(@NonNull RowViewHolder holder, int position) {
45: public int getItemCount() {
66: void bind(Notification notification) {
```

## app/src/main/java/com/amperly/app/ui/adapter/PendingStationAdapter.java

```
19: public class PendingStationAdapter extends RecyclerView.Adapter<PendingStationAdapter.PendingViewHolder> {
21: public interface Listener {
22: void onApprove(ChargerStation station);
23: void onReject(ChargerStation station);
29: public PendingStationAdapter(Listener listener) {
33: public void submit(List<ChargerStation> stations) {
43: public PendingViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
50: public void onBindViewHolder(@NonNull PendingViewHolder holder, int position) {
55: public int getItemCount() {
59: class PendingViewHolder extends RecyclerView.ViewHolder {
77: void bind(ChargerStation station) {
```

## app/src/main/java/com/amperly/app/ui/adapter/ReportAdapter.java

```
38: public class ReportAdapter extends RecyclerView.Adapter<ReportAdapter.ReportViewHolder> {
43: public interface Listener {
44: void onWarning(Report report);
46: void onSuspend(Report report);
48: void onBan(Report report);
57: public Item(@NonNull Report report, @Nullable String reporterName, @Nullable String targetName) {
64: public Report getReport() {
79: public ReportAdapter(@Nullable Listener listener) {
84: public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
90: public void onDetachedFromRecyclerView(@NonNull RecyclerView recyclerView) {
97: public void submit(@Nullable List<Item> reports) {
114: private void toggle(@NonNull String reportId) {
128: public ReportViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
135: public void onBindViewHolder(@NonNull ReportViewHolder holder, int position) {
140: public int getItemCount() {
144: class ReportViewHolder extends RecyclerView.ViewHolder {
172: void bind(Item item) {
```

## app/src/main/java/com/amperly/app/ui/adapter/ReservationAdapter.java

```
20: public class ReservationAdapter extends RecyclerView.Adapter<ReservationAdapter.ReservationViewHolder> {
22: public interface Listener {
23: void onOpenQr(Reservation reservation);
24: void onCheckIn(Reservation reservation);
25: void onMessageHost(Reservation reservation);
26: void onCancel(Reservation reservation);
32: public ReservationAdapter(Listener listener) {
36: public void submit(List<Reservation> reservations) {
46: public ReservationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
53: public void onBindViewHolder(@NonNull ReservationViewHolder holder, int position) {
58: public int getItemCount() {
62: class ReservationViewHolder extends RecyclerView.ViewHolder {
86: void bind(Reservation reservation) {
```

## app/src/main/java/com/amperly/app/ui/adapter/RouteStopAdapter.java

```
24: public class RouteStopAdapter extends RecyclerView.Adapter<RouteStopAdapter.StopViewHolder> {
26: public interface Listener {
27: void onReserveStop(String stationId, String stationName);
39: public StopRow(String badge, String sequenceLabel, String name, String detail, String reason,
50: public String getStationId() { return stationId; }
56: public RouteStopAdapter(Listener listener) {
60: public void submit(List<StopRow> newRows) {
68: public static StopRow fromCandidate(Context context,
86: public static StopRow fromPlannedStop(Context context, RoutePlannerEngine.PlannedStop stop) {
99: public StopViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
106: public void onBindViewHolder(@NonNull StopViewHolder holder, int position) {
111: public int getItemCount() {
115: class StopViewHolder extends RecyclerView.ViewHolder {
133: void bind(StopRow row) {
```

## app/src/main/java/com/amperly/app/ui/adapter/SessionAdapter.java

```
19: public class SessionAdapter extends RecyclerView.Adapter<SessionAdapter.SessionViewHolder> {
21: public interface Listener {
22: void onViewReceipt(ChargingSession session);
23: void onReportSession(ChargingSession session);
29: public SessionAdapter(Listener listener) {
33: public void submit(List<ChargingSession> sessions) {
43: public SessionViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
50: public void onBindViewHolder(@NonNull SessionViewHolder holder, int position) {
55: public int getItemCount() {
59: class SessionViewHolder extends RecyclerView.ViewHolder {
79: void bind(ChargingSession session) {
```

## app/src/main/java/com/amperly/app/ui/adapter/StationAdapter.java

```
27: public class StationAdapter extends RecyclerView.Adapter<StationAdapter.StationViewHolder> {
29: public interface Listener {
30: void onOpenStation(ChargerStation station);
33: void onSelectStation(ChargerStation station);
35: void onNavigateToStation(ChargerStation station);
45: public StationRow(ChargerStation station, AvailabilityEngine.AvailabilitySummary availability,
52: public ChargerStation getStation() { return station; }
53: public AvailabilityEngine.AvailabilitySummary getAvailability() { return availability; }
55: public Double getDistanceKm() { return distanceKm; }
64: public StationAdapter(Listener listener, com.amperly.app.data.local.entity.Vehicle vehicle) {
75: public void setVehicle(@Nullable com.amperly.app.data.local.entity.Vehicle vehicle) {
80: public void submit(List<StationRow> newRows) {
89: public void setSelectedStationId(@Nullable String stationId) {
100: public StationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
107: public void onBindViewHolder(@NonNull StationViewHolder holder, int position) {
112: public int getItemCount() {
116: class StationViewHolder extends RecyclerView.ViewHolder {
146: void bind(StationRow row) {
235: private void bindConnectors(ChargerStation station) {
248: private void addConnectorGlyph(int drawable, String label, boolean present) {
262: private int dp(int value) {
266: private String locationTypeLabel(String type) {
```

## app/src/main/java/com/amperly/app/ui/adapter/StationCardAdapter.java

```
27: public class StationCardAdapter extends RecyclerView.Adapter<StationCardAdapter.StationViewHolder> {
29: public interface Listener {
30: void onTogglePause(ChargerStation station);
32: void onEvidence(ChargerStation station);
38: public StationCardAdapter(Listener listener) {
42: public void submit(List<ChargerStation> stations) {
52: public StationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
59: public void onBindViewHolder(@NonNull StationViewHolder holder, int position) {
64: public int getItemCount() {
68: class StationViewHolder extends RecyclerView.ViewHolder {
88: void bind(ChargerStation station) {
```

## app/src/main/java/com/amperly/app/ui/adapter/VehicleCardAdapter.java

```
27: public class VehicleCardAdapter extends RecyclerView.Adapter<VehicleCardAdapter.VehicleViewHolder> {
29: public interface Listener {
30: void onEdit(Vehicle vehicle);
32: void onUse(Vehicle vehicle);
38: public VehicleCardAdapter(Listener listener) {
42: public void submit(List<Vehicle> vehicles) {
52: public VehicleViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
59: public void onBindViewHolder(@NonNull VehicleViewHolder holder, int position) {
64: public int getItemCount() {
68: class VehicleViewHolder extends RecyclerView.ViewHolder {
84: void bind(Vehicle vehicle) {
```

## app/src/main/java/com/amperly/app/ui/dialog/MeterEvidenceDialog.java

```
20: public final class MeterEvidenceDialog {
22: public interface OnSubmit {
23: void onSubmit(double startReading, double endReading, String note);
26: private MeterEvidenceDialog() {
29: public static void show(Fragment fragment, String stationName, String stationId,
67: private static double parse(String value, double fallback) {
```

## app/src/main/java/com/amperly/app/ui/dialog/PlaceSearchDialog.java

```
26: public final class PlaceSearchDialog {
28: public interface Listener {
29: void onPlaceSelected(@NonNull PlacesAutocomplete.Selection selection);
32: private PlaceSearchDialog() {
35: public static void show(@NonNull Fragment host, @Nullable Listener listener) {
56: public void onPlaceSelected(@NonNull PlacesAutocomplete.Selection selection) {
64: public void onSelectionCleared() {
68: public void onLookupFailed(@NonNull String message) {
```

## app/src/main/java/com/amperly/app/ui/dialog/ReportDialog.java

```
24: public final class ReportDialog {
26: public interface OnSubmit {
27: void onSubmit(String reportType, String details);
56: private ReportDialog() {
59: public static void show(Fragment fragment, String title, String selectedType, OnSubmit onSubmit) {
113: private static String[] typeLabels(Context context) {
```

## app/src/main/java/com/amperly/app/ui/dialog/VehicleSwitcherDialog.java

```
27: public final class VehicleSwitcherDialog {
30: public interface Listener {
32: void onVehicleSwitched(@NonNull Vehicle vehicle);
35: void onManageVehicles();
38: private VehicleSwitcherDialog() {
48: public static void show(@NonNull Fragment host, @Nullable String activeVehicleId,
94: private static void switchTo(@NonNull Fragment host, @NonNull AmperlyRepository repo,
```
