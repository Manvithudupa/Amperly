package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.common.MapConfig;
import com.amperly.app.core.location.LocationProvider;
import com.amperly.app.core.map.MapPanel;
import com.amperly.app.core.nav.GeoapifyNavigationProvider;
import com.amperly.app.core.nav.NavigationProvider;
import com.amperly.app.core.nav.NavigationState;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.nav.RouteProgress;
import com.amperly.app.core.routing.DirectionsRoute;
import com.amperly.app.core.routing.GeoapifyRoutingClient;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.core.state.SocStore;
import com.amperly.app.ui.Ux;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * In-app navigation, inside Amperly, on the MapLibre map.
 *
 * <p>The route comes from the Geoapify {@link NavigationProvider}; the map is MapLibre; the
 * driver-safe strip shows only the next maneuver, the remaining distance and the ETA. While the
 * session is active the screen re-reads the device position on a short timer and advances the
 * progress along the real road geometry — it never keeps announcing a stale instruction after the
 * session stops.
 *
 * <p>Spoken voice guidance is deliberately not simulated here: it needs a licensed navigation
 * SDK and an audio-focus policy this build does not ship. The screen says so rather than
 * pretending to speak.
 */
public class InAppNavigationFragment extends Fragment {

    public static final String ARG_ORIGIN_LAT = "origin_lat";
    public static final String ARG_ORIGIN_LNG = "origin_lng";
    public static final String ARG_DEST_LAT = "dest_lat";
    public static final String ARG_DEST_LNG = "dest_lng";
    public static final String ARG_LABEL = "label";

    private static final long PROGRESS_INTERVAL_MS = 6000L;

    private final NavigationProvider provider = new GeoapifyNavigationProvider();
    private final Handler handler = new Handler(Looper.getMainLooper());

    private TextView nextTurnText;
    private TextView instructionText;
    private TextView remainingText;
    private TextView etaText;
    private TextView statusText;
    private MapPanel mapPanel;

    private double originLat;
    private double originLng;
    private double destLat;
    private double destLng;
    private String label = "";
    private DirectionsRoute route;
    private boolean navigating;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_in_app_navigation, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        Bundle args = getArguments();
        if (args == null) {
            Ux.error(this, getString(R.string.nav_route_failed));
            return;
        }
        originLat = args.getDouble(ARG_ORIGIN_LAT);
        originLng = args.getDouble(ARG_ORIGIN_LNG);
        destLat = args.getDouble(ARG_DEST_LAT);
        destLng = args.getDouble(ARG_DEST_LNG);
        String rawLabel = args.getString(ARG_LABEL);
        label = rawLabel == null || rawLabel.isEmpty()
                ? getString(R.string.nav_destination_fallback) : rawLabel;

        nextTurnText = view.findViewById(R.id.navNextTurnText);
        instructionText = view.findViewById(R.id.navInstructionText);
        remainingText = view.findViewById(R.id.navRemainingText);
        etaText = view.findViewById(R.id.navEtaText);
        statusText = view.findViewById(R.id.navStatusText);

        view.findViewById(R.id.navStopButton).setOnClickListener(v -> stopNavigation());
        view.findViewById(R.id.navUpdateBatteryButton).setOnClickListener(v -> promptBatteryUpdate());

        ViewGroup mapContainer = view.findViewById(R.id.navMapContainer);
        MapPanel.attach(this, mapContainer, panel -> {
            mapPanel = panel;
            startNavigation();
        });

        if (!MapConfig.isConfigured()) {
            statusText.setVisibility(View.VISIBLE);
            statusText.setText(MapConfig.setupMessage(requireContext()));
        }
    }

    private void startNavigation() {
        if (!MapConfig.isConfigured()) {
            return;
        }
        statusText.setVisibility(View.VISIBLE);
        statusText.setText(R.string.nav_starting);
        NavigationProvider.RouteRequest request = new NavigationProvider.RouteRequest(originLat,
                originLng, destLat, destLng, null, GeoapifyRoutingClient.TravelMode.DRIVING);
        provider.calculateRoute(request, new NavigationProvider.RouteCallback() {
            @Override
            public void onRoute(@NonNull NavigationProvider.RouteResult result) {
                if (!isAdded()) {
                    return;
                }
                route = result.getRoute();
                provider.startNavigation(new NavigationProvider.NavigationRequest(result,
                                GeoapifyNavigationProvider.AUDIO_VOICE_ALERTS_AND_GUIDANCE
                                        | GeoapifyNavigationProvider.AUDIO_BLUETOOTH),
                        new NavigationProvider.NavigationCallback() {
                            @Override
                            public void onStarted(@NonNull NavigationState state) {
                                navigating = true;
                                render(state);
                                // The route was fetched but never drawn, so the map sat on a world
                                // view with no line and no destination. Draw it before following.
                                plotNavigation();
                                statusText.setVisibility(View.GONE);
                                scheduleProgress();
                            }

                            @Override
                            public void onRerouted(@NonNull NavigationState state) {
                                render(state);
                                plotNavigation();
                            }

                            @Override
                            public void onArrived(@NonNull NavigationState state) {
                                arriving();
                            }

                            @Override
                            public void onStopped() {
                            }

                            @Override
                            public void onError(@NonNull String message) {
                                showStatus(message);
                            }
                        });
            }

            @Override
            public void onError(@NonNull String message) {
                if (isAdded()) {
                    showStatus(message);
                }
            }
        });
    }

    /** Keeps the next-maneuver card current by re-reading the device position on a short timer. */
    private void scheduleProgress() {
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (!navigating || !isAdded()) {
                    return;
                }
                refreshProgress();
                handler.postDelayed(this, PROGRESS_INTERVAL_MS);
            }
        }, PROGRESS_INTERVAL_MS);
    }

    private void refreshProgress() {
        if (route == null || mapPanel == null) {
            return;
        }
        if (!LocationProvider.hasLocationPermission(requireContext())) {
            return;
        }
        LocationProvider.requestCurrentLocation(requireContext(),
                new LocationProvider.LocationCallback() {
                    @Override
                    public void onLocationRetrieved(double latitude, double longitude) {
                        if (isAdded() && navigating) {
                            applyPosition(latitude, longitude);
                        }
                    }
                });
    }

    /** Draws the road route, its endpoints and the driver, then frames the trip. */
    private void plotNavigation() {
        if (mapPanel == null || route == null) {
            return;
        }
        mapPanel.plotRoute(route, originLat, originLng, destLat, destLng, null, null);
        mapPanel.plotDriverPosition(originLat, originLng);
    }

    private void applyPosition(double latitude, double longitude) {
        DirectionsRoute current = route;
        if (current == null || current.getPoints().size() < 2) {
            return;
        }
        double fraction = RouteProgress.fractionAlong(current.getPoints(), latitude, longitude);
        double remainingKm = RouteProgress.remainingKm(current, fraction);
        int remainingMinutes = RouteProgress.remainingMinutes(current, fraction);

        GeoapifyNavigationProvider geoapify = provider instanceof GeoapifyNavigationProvider
                ? (GeoapifyNavigationProvider) provider : null;
        if (geoapify != null) {
            geoapify.updateProgress(latitude, longitude, remainingKm, remainingMinutes,
                    (int) Math.round(fraction * 100));
        }
        render(provider.getCurrentNavigationState());
        mapPanel.plotDriverPosition(latitude, longitude);
        // Follows the driver, but yields for a few seconds after they pan the map themselves.
        mapPanel.followUser(latitude, longitude, 17f);
    }

    private void render(@Nullable NavigationState state) {
        DirectionsRoute current = state != null && state.getRoute() != null ? state.getRoute() : route;
        if (current == null) {
            return;
        }
        double fraction = state == null ? 0 : state.getTravelledPercent() / 100d;
        double remainingKm = state == null ? current.getDistanceKm() : state.getRemainingDistanceKm();
        int remainingMinutes = state == null ? current.getEffectiveDurationMinutes()
                : state.getRemainingMinutes();

        DirectionsRoute.Step next = RouteProgress.nextStep(current, fraction);
        if (next != null && !next.getInstruction().isEmpty()) {
            nextTurnText.setVisibility(View.VISIBLE);
            nextTurnText.setText(getString(R.string.nav_next_maneuver,
                    next.getDistanceText().isEmpty()
                            ? getString(R.string.nav_continue) : next.getDistanceText()));
            instructionText.setText(next.getInstruction());
        } else {
            nextTurnText.setVisibility(View.VISIBLE);
            nextTurnText.setText(getString(R.string.nav_next_maneuver,
                    getString(R.string.nav_continue)));
            instructionText.setText(getString(R.string.nav_continue_to, label));
        }

        remainingText.setText(getString(R.string.nav_remaining, remainingKm,
                Formatters.minutes(remainingMinutes)));
        etaText.setText(getString(R.string.nav_eta, arrivalClock(remainingMinutes),
                (int) Math.round(fraction * 100)));
    }

    private String arrivalClock(int remainingMinutes) {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.MINUTE, Math.max(0, remainingMinutes));
        return new SimpleDateFormat("HH:mm", Locale.US).format(new Date(calendar.getTimeInMillis()));
    }

    private void arriving() {
        navigating = false;
        handler.removeCallbacksAndMessages(null);
        Ux.toast(this, getString(R.string.nav_arrived, label));
        provider.stopNavigation();
        if (isAdded()) {
            Navigator.pop(this);
        }
    }

    private void promptBatteryUpdate() {
        View content = LayoutInflater.from(requireContext())
                .inflate(R.layout.dialog_input_number, null, false);
        final TextInputLayout field = content.findViewById(R.id.numberField);
        final TextInputEditText input = content.findViewById(R.id.numberInput);
        input.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                field.setError(null);
            }
        });

        final androidx.appcompat.app.AlertDialog dialog = new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.soc_update_title)
                .setMessage(R.string.soc_update_message)
                .setView(content)
                .setNegativeButton(R.string.action_close, null)
                .setPositiveButton(R.string.soc_update_action, null)
                .create();

        // Validated inside the dialog: an out-of-range value keeps it open and marks the field.
        dialog.setOnShowListener(ignored -> dialog
                .getButton(androidx.appcompat.app.AlertDialog.BUTTON_POSITIVE)
                .setOnClickListener(v -> {
                    int soc = parseInt(input.getText() == null ? "" : input.getText().toString());
                    if (soc < 0 || soc > 100) {
                        field.setError(getString(R.string.soc_update_invalid));
                        return;
                    }
                    field.setError(null);
                    dialog.dismiss();
                    AppStateStore.get().applySocCorrection(AppStateStore.get().getCurrentSoc(), soc);
                    SocStore.save(getContext(), AuthManager.getInstance().getCurrentUserId(), soc);
                    AppStateStore.get().setLastRecalculationSummary(
                            getString(R.string.soc_update_authoritative, soc));
                    recalculateFromPosition();
                }));
        dialog.show();
        input.requestFocus();
    }

    /** Recalculates from the latest real position after the driver corrects the battery. */
    private void recalculateFromPosition() {
        if (!LocationProvider.hasLocationPermission(requireContext())) {
            return;
        }
        LocationProvider.requestCurrentLocation(requireContext(),
                new LocationProvider.LocationCallback() {
                    @Override
                    public void onLocationRetrieved(double latitude, double longitude) {
                        if (!isAdded()) {
                            return;
                        }
                        originLat = latitude;
                        originLng = longitude;
                        showStatus(getString(R.string.nav_off_route));
                        NavigationProvider.RouteRequest request = new NavigationProvider.RouteRequest(
                                latitude, longitude, destLat, destLng, null,
                                GeoapifyRoutingClient.TravelMode.DRIVING);
                        provider.recalculate(request, new NavigationProvider.RouteCallback() {
                            @Override
                            public void onRoute(@NonNull NavigationProvider.RouteResult result) {
                                if (!isAdded()) {
                                    return;
                                }
                                route = result.getRoute();
                                if (provider instanceof GeoapifyNavigationProvider) {
                                    ((GeoapifyNavigationProvider) provider).applyReroute(route, null);
                                }
                                plotNavigation();
                                render(provider.getCurrentNavigationState());
                                statusText.setVisibility(View.GONE);
                            }

                            @Override
                            public void onError(@NonNull String message) {
                                showStatus(message);
                            }
                        });
                    }
                });
    }

    private void stopNavigation() {
        navigating = false;
        handler.removeCallbacksAndMessages(null);
        provider.stopNavigation();
        if (isAdded()) {
            Navigator.pop(this);
        }
    }

    private void showStatus(String message) {
        statusText.setVisibility(View.VISIBLE);
        statusText.setText(message);
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        // Navigation must not keep announcing stale instructions once the screen is gone.
        handler.removeCallbacksAndMessages(null);
    }
}
