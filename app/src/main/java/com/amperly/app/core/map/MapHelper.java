package com.amperly.app.core.map;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.amperly.app.BuildConfig;
import com.amperly.app.R;
import com.amperly.app.data.local.entity.ChargerStation;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;
import java.util.List;

/**
 * Adds a Google Maps panel when a MAPS_API_KEY is configured, and otherwise provides
 * a clean fallback card with a direct Google Maps launcher.
 */
public final class MapHelper {

    public interface MapReady {
        void onReady(GoogleMap map);
    }

    /** One map panel per container. Every later attach on the same screen finds this one. */
    private static final String MAP_TAG_PREFIX = "amperly_map_";

    private MapHelper() {
    }

    /**
     * Shows a map inside {@code container}, reusing the panel already there.
     *
     * <p>The container itself is the fragment's view group, so the transaction targets a
     * real resource id that stays attached for as long as the screen does. An earlier
     * version hosted the map in a view with a generated id and cleared the container on
     * every call; a screen that asks for its map twice (discovery loads once when the view
     * is created and again in {@code onResume}) then took the first panel's view away
     * while its fragment transaction was still queued, and the queued transaction threw
     * {@code IllegalArgumentException: No view found for id ...} on the main thread — which
     * closes the app. Reusing the panel keeps one {@link GoogleMap} per screen as well.
     */
    public static void attach(@NonNull Fragment parent, @Nullable ViewGroup container, @NonNull MapReady callback) {
        if (container == null) {
            return;
        }
        if (!BuildConfig.MAPS_ENABLED) {
            container.removeAllViews();
            container.addView(keyMissingView(parent));
            return;
        }

        if (container.getId() == View.NO_ID) {
            container.setId(ViewGroup.generateViewId());
        }
        String tag = MAP_TAG_PREFIX + container.getId();
        FragmentManager fragments = parent.getChildFragmentManager();

        Fragment existing = fragments.findFragmentByTag(tag);
        if (existing instanceof SupportMapFragment) {
            ((SupportMapFragment) existing).getMapAsync(callback::onReady);
            return;
        }

        try {
            container.removeAllViews();
            SupportMapFragment mapFragment = SupportMapFragment.newInstance();
            fragments.beginTransaction()
                    .replace(container.getId(), mapFragment, tag)
                    .commitAllowingStateLoss();
            mapFragment.getMapAsync(callback::onReady);
        } catch (Exception e) {
            container.removeAllViews();
            container.addView(keyMissingView(parent));
        }
    }

    private static View keyMissingView(Fragment parent) {
        LinearLayout layout = new LinearLayout(parent.requireContext());
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER);
        layout.setPadding(32, 24, 32, 24);
        layout.setBackgroundColor(ContextCompat.getColor(parent.requireContext(), R.color.amp_surface_variant));

        TextView text = new TextView(parent.requireContext());
        text.setText("Map View\nAdd MAPS_API_KEY to local.properties to display embedded map.");
        text.setGravity(Gravity.CENTER);
        text.setTextSize(13f);
        text.setTextColor(ContextCompat.getColor(parent.requireContext(), R.color.amp_on_surface_variant));
        layout.addView(text);

        com.google.android.material.button.MaterialButton openMapsBtn =
                new com.google.android.material.button.MaterialButton(parent.requireContext());
        openMapsBtn.setText(R.string.map_open_external);
        openMapsBtn.setTextSize(12f);
        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.topMargin = 12;
        openMapsBtn.setLayoutParams(params);

        openMapsBtn.setOnClickListener(v -> {
            try {
                Uri gmmIntentUri = Uri.parse("geo:12.2958,76.6394?q=EV+Charger+Station");
                Intent mapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                mapIntent.setPackage("com.google.android.apps.maps");
                if (mapIntent.resolveActivity(parent.requireContext().getPackageManager()) != null) {
                    parent.startActivity(mapIntent);
                } else {
                    Intent genericMapIntent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                    parent.startActivity(genericMapIntent);
                }
            } catch (Exception ignored) {}
        });

        layout.addView(openMapsBtn);
        return layout;
    }

    public static void plotStations(@Nullable GoogleMap map, @Nullable List<ChargerStation> stations,
                                    @Nullable String highlightStationId) {
        if (map == null || stations == null || stations.isEmpty()) {
            return;
        }
        try {
            map.clear();
            LatLngBounds.Builder bounds = new LatLngBounds.Builder();
            boolean hasPoint = false;
            for (ChargerStation station : stations) {
                LatLng position = new LatLng(station.getLatitude(), station.getLongitude());
                boolean highlight = station.getId().equals(highlightStationId);
                map.addMarker(new MarkerOptions()
                        .position(position)
                        .title(station.getName())
                        .snippet(station.getAddress())
                        .icon(BitmapDescriptorFactory.defaultMarker(highlight
                                ? BitmapDescriptorFactory.HUE_AZURE
                                : station.supportsPaidEnergyBilling()
                                ? BitmapDescriptorFactory.HUE_GREEN
                                : BitmapDescriptorFactory.HUE_ORANGE)));
                bounds.include(position);
                hasPoint = true;
            }
            if (hasPoint) {
                try {
                    map.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds.build(), 120));
                } catch (IllegalStateException ignored) {
                    map.moveCamera(CameraUpdateFactory.newLatLngZoom(
                            new LatLng(stations.get(0).getLatitude(), stations.get(0).getLongitude()), 11f));
                }
            }
        } catch (Exception ignored) {}
    }

    public static void plotRoute(@Nullable GoogleMap map, double originLat, double originLng,
                                 double destLat, double destLng,
                                 @Nullable List<ChargerStation> corridorStations,
                                 @Nullable String highlightStationId) {
        if (map == null) {
            return;
        }
        try {
            map.clear();
            LatLng origin = new LatLng(originLat, originLng);
            LatLng destination = new LatLng(destLat, destLng);
            map.addPolyline(new PolylineOptions()
                    .add(origin, destination)
                    .width(10f)
                    .color(Color.parseColor("#1B6FE3")));

            List<ChargerStation> markers = corridorStations == null
                    ? new ArrayList<>() : new ArrayList<>(corridorStations);
            if (!markers.isEmpty()) {
                plotStations(map, markers, highlightStationId);
            }

            LatLngBounds.Builder bounds = new LatLngBounds.Builder()
                    .include(origin)
                    .include(destination);
            for (ChargerStation station : markers) {
                bounds.include(new LatLng(station.getLatitude(), station.getLongitude()));
            }
            try {
                map.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds.build(), 140));
            } catch (IllegalStateException ignored) {
                map.moveCamera(CameraUpdateFactory.newLatLngZoom(origin, 9f));
            }
        } catch (Exception ignored) {}
    }
}
