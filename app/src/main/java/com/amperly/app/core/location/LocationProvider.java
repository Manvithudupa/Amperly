package com.amperly.app.core.location;

import android.content.Context;
import android.location.Location;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;

public class LocationProvider {

    public interface LocationCallback {
        void onLocationRetrieved(double latitude, double longitude);
    }

    public static void getCurrentLocation(Context context, LocationCallback callback) {
        try {
            FusedLocationProviderClient client = LocationServices.getFusedLocationProviderClient(context);
            client.getLastLocation().addOnSuccessListener(location -> {
                if (location != null) {
                    callback.onLocationRetrieved(location.getLatitude(), location.getLongitude());
                } else {
                    // Fallback Mysore coordinates
                    callback.onLocationRetrieved(12.2958, 76.6394);
                }
            }).addOnFailureListener(e -> callback.onLocationRetrieved(12.2958, 76.6394));
        } catch (SecurityException e) {
            // Permission missing fallback
            callback.onLocationRetrieved(12.2958, 76.6394);
        }
    }
}
