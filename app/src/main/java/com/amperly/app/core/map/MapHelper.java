package com.amperly.app.core.map;

import android.graphics.Color;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

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
 * Adds a Google Maps panel when a MAPS_API_KEY is configured, and otherwise degrades gracefully to
 * an explanatory card. Regardless of the key, every station still offers a hand-off to the phone's
 * installed maps application so navigation always works.
 */
public final class MapHelper {

    public interface MapReady {
        void onReady(GoogleMap map);
    }

    private MapHelper() {
    }

    public static void attach(@NonNull Fragment parent, @Nullable ViewGroup container, @NonNull MapReady callback) {
        if (container == null) {
            return;
        }
        if (!BuildConfig.MAPS_ENABLED) {
            container.removeAllViews();
            container.addView(keyMissingView(parent));
            return;
        }
        container.removeAllViews();
        LinearLayout host = new LinearLayout(parent.requireContext());
        host.setOrientation(LinearLayout.VERTICAL);
        host.setId(ViewGroup.generateViewId());
        container.addView(host, new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        SupportMapFragment mapFragment = SupportMapFragment.newInstance();
        parent.getChildFragmentManager()
                .beginTransaction()
                .replace(host.getId(), mapFragment, "amperly_map_" + container.getId())
                .commitNow();
        mapFragment.getMapAsync(callback::onReady);
    }

    private static TextView keyMissingView(Fragment parent) {
        TextView text = new TextView(parent.requireContext());
        text.setText(R.string.map_key_missing);
        text.setGravity(Gravity.CENTER);
        text.setPadding(32, 32, 32, 32);
        text.setTextColor(ContextCompat.getColor(parent.requireContext(), R.color.amp_on_surface_variant));
        text.setBackgroundColor(ContextCompat.getColor(parent.requireContext(), R.color.amp_surface_variant));
        return text;
    }

    public static void plotStations(@Nullable GoogleMap map, @Nullable List<ChargerStation> stations,
                                    @Nullable String highlightStationId) {
        if (map == null || stations == null || stations.isEmpty()) {
            return;
        }
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
                // Layout not measured yet; fall back to the first station.
                map.moveCamera(CameraUpdateFactory.newLatLngZoom(
                        new LatLng(stations.get(0).getLatitude(), stations.get(0).getLongitude()), 11f));
            }
        }
    }

    public static void plotRoute(@Nullable GoogleMap map, double originLat, double originLng,
                                 double destLat, double destLng,
                                 @Nullable List<ChargerStation> corridorStations,
                                 @Nullable String highlightStationId) {
        if (map == null) {
            return;
        }
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
    }
}
