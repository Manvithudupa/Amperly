package com.amperly.app.core.places;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.core.common.GoogleConfig;
import com.google.android.libraries.places.api.Places;
import com.google.android.libraries.places.api.model.AutocompletePrediction;
import com.google.android.libraries.places.api.model.Place;
import com.google.android.libraries.places.api.net.FetchPlaceRequest;
import com.google.android.libraries.places.api.net.FindAutocompletePredictionsRequest;
import com.google.android.libraries.places.api.net.PlacesClient;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Destination and address entry through Google Place autocomplete.
 *
 * <p>The driver types a shop, hotel, office, landmark or town and picks the real place; Amperly
 * keeps the Place ID, the formatted address and the coordinates, and never stores anything else
 * about the user's search.
 *
 * <p>Only the fields the flow genuinely needs are requested
 * ({@code ID}, {@code DISPLAY_NAME}, {@code FORMATTED_ADDRESS}, {@code LAT_LNG}), in line with
 * Google's field-masking guidance. Everything degrades gracefully when the key is missing or the
 * service is unreachable: the plain text field keeps working and the screen says so.
 */
public final class PlacesAutocomplete {

    /** A place the driver chose. */
    public static final class Selection {
        private final String placeId;
        private final String label;
        private final String address;
        private final double latitude;
        private final double longitude;

        public Selection(String placeId, String label, String address, double latitude,
                         double longitude) {
            this.placeId = placeId;
            this.label = label;
            this.address = address;
            this.latitude = latitude;
            this.longitude = longitude;
        }

        @NonNull public String getPlaceId() { return placeId == null ? "" : placeId; }
        @NonNull public String getLabel() { return label == null ? "" : label; }
        @NonNull public String getAddress() { return address == null ? "" : address; }
        public double getLatitude() { return latitude; }
        public double getLongitude() { return longitude; }
    }

    /** Reports the chosen place, or that the driver typed free text with no Google match. */
    public interface Listener {
        void onPlaceSelected(@NonNull Selection selection);

        /** The text no longer matches a Google place (they edited it after choosing). */
        void onSelectionCleared();
    }

    private static volatile boolean initialized;
    @Nullable private static PlacesClient client;

    private PlacesAutocomplete() {
    }

    /** True when Place autocomplete can run (key present and the SDK initialised). */
    public static boolean isAvailable(@NonNull Context context) {
        return GoogleConfig.isConfigured() && client(context) != null;
    }

    @Nullable
    private static synchronized PlacesClient client(@NonNull Context context) {
        if (!GoogleConfig.isConfigured()) {
            return null;
        }
        if (client == null) {
            try {
                if (!initialized) {
                    Places.initialize(context.getApplicationContext(), GoogleConfig.apiKey());
                    initialized = true;
                }
                client = Places.createClient(context.getApplicationContext());
            } catch (Exception e) {
                client = null;
            }
        }
        return client;
    }

    /**
     * Wires autocomplete onto a text field. Suggestions appear as the driver types; the chosen
     * place is resolved to coordinates in the background.
     */
    public static void bind(@NonNull Context context, @NonNull AutoCompleteTextView field,
                            @NonNull Listener listener) {
        PlacesClient places = client(context);
        if (places == null) {
            field.setHint("Search a town, shop, hotel or landmark");
            field.setOnFocusChangeListener(null);
            return;
        }
        final List<AutocompletePrediction> predictions = new ArrayList<>();
        final ArrayAdapter<AutocompletePrediction> adapter = new ArrayAdapter<>(context,
                android.R.layout.simple_list_item_1, predictions) {
            @NonNull
            @Override
            public android.view.View getView(int position, @Nullable android.view.View convertView,
                                             @NonNull android.view.ViewGroup parent) {
                android.view.View view = super.getView(position, convertView, parent);
                if (view instanceof android.widget.TextView) {
                    ((android.widget.TextView) view).setText(
                            predictions.get(position).getFullText(null).toString());
                }
                return view;
            }
        };
        field.setAdapter(adapter);
        field.setThreshold(2);

        // The item the user picked; cleared as soon as they edit the text again, so a stale place
        // can never be routed to silently.
        final Selection[] chosen = new Selection[1];
        final boolean[] suppress = {false};

        field.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (suppress[0]) {
                    return;
                }
                if (chosen[0] != null) {
                    chosen[0] = null;
                    listener.onSelectionCleared();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (suppress[0]) {
                    return;
                }
                String query = s == null ? "" : s.toString().trim();
                if (query.length() < 2) {
                    predictions.clear();
                    adapter.notifyDataSetChanged();
                    return;
                }
                FindAutocompletePredictionsRequest request = FindAutocompletePredictionsRequest
                        .builder().setQuery(query).build();
                places.findAutocompletePredictions(request)
                        .addOnSuccessListener(response -> {
                            predictions.clear();
                            predictions.addAll(response.getAutocompletePredictions());
                            adapter.notifyDataSetChanged();
                        })
                        .addOnFailureListener(e -> {
                            predictions.clear();
                            adapter.notifyDataSetChanged();
                        });
            }
        });

        field.setOnItemClickListener((parent, view, position, id) -> {
            if (position < 0 || position >= predictions.size()) {
                return;
            }
            AutocompletePrediction prediction = predictions.get(position);
            suppress[0] = true;
            field.setText(prediction.getPrimaryText(null).toString(), false);
            field.dismissDropDown();
            suppress[0] = false;

            // Field masking: only the identity, name, address and coordinates are requested, and
            // nothing else about the driver's search is kept.
            List<Place.Field> fields = Arrays.asList(Place.Field.ID, Place.Field.NAME,
                    Place.Field.ADDRESS, Place.Field.LAT_LNG);
            FetchPlaceRequest fetch = FetchPlaceRequest.builder(prediction.getPlaceId(), fields).build();
            places.fetchPlace(fetch).addOnSuccessListener(response -> {
                Place place = response.getPlace();
                if (place.getLatLng() == null) {
                    return;
                }
                String label = place.getName() != null
                        ? place.getName() : prediction.getPrimaryText(null).toString();
                String address = place.getAddress() != null
                        ? place.getAddress() : prediction.getFullText(null).toString();
                Selection selection = new Selection(place.getId(), label, address,
                        place.getLatLng().latitude, place.getLatLng().longitude);
                chosen[0] = selection;
                listener.onPlaceSelected(selection);
            });
        });
    }
}
