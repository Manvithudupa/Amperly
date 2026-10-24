package com.amperly.app.core.places;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Filter;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.R;
import com.amperly.app.core.common.GeoapifyErrors;
import com.amperly.app.core.common.MapConfig;
import com.amperly.app.core.common.RequestSequence;
import com.amperly.app.core.common.UserMessages;
import com.amperly.app.core.location.LocationProvider;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * Destination and address entry through Geoapify autocomplete (OpenStreetMap data).
 *
 * <p>The driver types a shop, hotel, office, landmark or town and picks the real place; Amperly
 * keeps the place id, the formatted address and the coordinates, and never stores anything else
 * about the user's search. Geoapify returns the coordinates with the suggestion, so there is no
 * second "fetch place" round trip and no credit spent on one.
 *
 * <p>Three things keep the free plan usable and the list honest:
 * <ul>
 *   <li>typing is debounced, so a request is never fired per keystroke (the plan allows about five
 *       requests per second);</li>
 *   <li>a request token is compared before the answer is applied, so a slow answer for "Kor" can
 *       never replace the newer list for "Koramangala";</li>
 *   <li>fewer than three characters never searches at all.</li>
 * </ul>
 *
 * <p>Everything degrades gracefully when the key is missing or the service is unreachable: the
 * plain text field keeps working and the screen says why.
 */
public final class PlacesAutocomplete {

    private static final String TAG = "PlacesAutocomplete";
    /** Waits this long after the last keystroke before searching. */
    private static final long DEBOUNCE_MS = 300L;
    /** Shorter queries are refused: they match half a continent and waste credits. */
    private static final int MIN_QUERY_LENGTH = 3;
    /** The free plan returns at most five; asking for more would not help. */
    private static final int MAX_RESULTS = 5;

    private static final OkHttpClient HTTP = new OkHttpClient.Builder()
            .connectTimeout(8, TimeUnit.SECONDS)
            .readTimeout(12, TimeUnit.SECONDS)
            .build();

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

    /** Reports the chosen place, or that the driver typed free text with no match. */
    public interface Listener {
        void onPlaceSelected(@NonNull Selection selection);

        /** The text no longer matches a chosen place (they edited it after choosing). */
        void onSelectionCleared();

        /**
         * The lookup could not answer (no key in this build, no connectivity, or the quota is
         * spent). Defaulted to a no-op so that a caller with nowhere to show the message still
         * compiles.
         */
        default void onLookupFailed(@NonNull String message) {
        }
    }

    private PlacesAutocomplete() {
    }

    /** True when address search can run, which is exactly "a key was configured". */
    public static boolean isAvailable(@NonNull Context context) {
        return MapConfig.isConfigured();
    }

    /**
     * Wires autocomplete onto a text field. Suggestions appear as the driver types; the chosen
     * place already carries its coordinates, so nothing else is fetched.
     */
    public static void bind(@NonNull Context context, @NonNull AutoCompleteTextView field,
                            @NonNull Listener listener) {
        if (!MapConfig.isConfigured()) {
            field.setHint(R.string.route_destination_hint);
            field.setOnFocusChangeListener(null);
            return;
        }
        final Context appContext = context.getApplicationContext();
        final List<Selection> suggestions = new ArrayList<>();
        final ArrayAdapter<Selection> adapter = new ArrayAdapter<Selection>(context,
                R.layout.item_place_suggestion, suggestions) {

            /**
             * Geoapify has already matched these suggestions to what the driver typed, so the
             * adapter hands that list straight back.
             *
             * <p>{@link ArrayAdapter}'s own filter compares {@link Selection#toString()} with the
             * query, which never matches. It would therefore empty the list, replace the adapter's
             * backing list with that empty result and report a count of zero, so the field would
             * look like it had no suggestions at all and the drop-down would never open.
             */
            @NonNull
            @Override
            public Filter getFilter() {
                return new Filter() {
                    @Override
                    protected FilterResults performFiltering(CharSequence constraint) {
                        FilterResults results = new FilterResults();
                        results.values = suggestions;
                        results.count = suggestions.size();
                        return results;
                    }

                    @Override
                    protected void publishResults(CharSequence constraint, FilterResults results) {
                        notifyDataSetChanged();
                    }
                };
            }

            @NonNull
            @Override
            public View getView(int position, @Nullable View convertView,
                                @NonNull ViewGroup parent) {
                View view = convertView != null ? convertView
                        : LayoutInflater.from(getContext()).inflate(
                                R.layout.item_place_suggestion, parent, false);
                Selection suggestion = position >= 0 && position < suggestions.size()
                        ? suggestions.get(position) : null;
                TextView primary = view.findViewById(R.id.placePrimaryText);
                TextView secondary = view.findViewById(R.id.placeSecondaryText);
                primary.setText(suggestion == null ? "" : suggestion.getLabel());
                if (secondary != null) {
                    String detail = suggestion == null ? "" : suggestion.getAddress();
                    if (detail.isEmpty()) {
                        detail = suggestion == null ? "" : suggestion.getLabel();
                    }
                    secondary.setText(detail);
                }
                return view;
            }
        };
        field.setAdapter(adapter);
        field.setThreshold(MIN_QUERY_LENGTH);

        final Handler main = new Handler(Looper.getMainLooper());
        final RequestSequence sequence = new RequestSequence();
        // The item the user picked; cleared as soon as they edit the text again, so a stale place
        // can never be routed to silently.
        final Selection[] chosen = new Selection[1];
        final boolean[] suppress = {false};
        final Runnable[] pending = new Runnable[1];

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
                if (pending[0] != null) {
                    main.removeCallbacks(pending[0]);
                    pending[0] = null;
                }
                String query = s == null ? "" : s.toString().trim();
                // Anything already in flight belongs to the previous query and must be ignored,
                // even if this new text is too short to search for.
                final int token = sequence.next();
                if (query.length() < MIN_QUERY_LENGTH) {
                    suggestions.clear();
                    adapter.notifyDataSetChanged();
                    field.dismissDropDown();
                    return;
                }
                final String searchFor = query;
                Runnable task = () -> search(appContext, searchFor, token, sequence, suggestions,
                        adapter, field, listener);
                pending[0] = task;
                main.postDelayed(task, DEBOUNCE_MS);
            }
        });

        field.setOnItemClickListener((parent, view, position, id) -> {
            if (position < 0 || position >= suggestions.size()) {
                return;
            }
            Selection selection = suggestions.get(position);
            suppress[0] = true;
            field.setText(selection.getLabel(), false);
            field.dismissDropDown();
            suppress[0] = false;
            chosen[0] = selection;
            listener.onPlaceSelected(selection);
        });
    }

    /** Runs one search off the main thread and applies it only while it is still the newest. */
    private static void search(@NonNull Context appContext, @NonNull String query, int token,
                               @NonNull RequestSequence sequence,
                               @NonNull List<Selection> suggestions,
                               @NonNull ArrayAdapter<Selection> adapter,
                               @NonNull AutoCompleteTextView field,
                               @NonNull Listener listener) {
        new Thread(() -> {
            try {
                double biasLat = Double.NaN;
                double biasLng = Double.NaN;
                double[] fix = LocationProvider.lastKnownFix();
                if (fix != null && fix.length == 2) {
                    biasLat = fix[0];
                    biasLng = fix[1];
                }
                String url = GeoapifyGeocoder.autocompleteUrl(query, MAX_RESULTS, biasLat, biasLng);
                String json = fetch(url);
                if (!sequence.isCurrent(token)) {
                    return;
                }
                List<Selection> parsed = GeoapifyPlaceParser.parseSuggestions(json, MAX_RESULTS);
                new Handler(Looper.getMainLooper()).post(() -> {
                    if (!sequence.isCurrent(token)) {
                        return;
                    }
                    suggestions.clear();
                    suggestions.addAll(parsed);
                    adapter.notifyDataSetChanged();
                    // notifyDataSetChanged() opens the drop-down through the field's own
                    // data-set observer; asking again covers the response landing while the
                    // driver is still typing, which is the normal case for a slow lookup.
                    if (!suggestions.isEmpty() && field.hasFocus() && field.hasWindowFocus()) {
                        field.showDropDown();
                    }
                });
            } catch (Exception e) {
                if (!sequence.isCurrent(token)) {
                    return;
                }
                Log.w(TAG, "Place search failed", e);
                String message = UserMessages.from(appContext, e, R.string.error_place_search);
                new Handler(Looper.getMainLooper()).post(() -> {
                    if (sequence.isCurrent(token)) {
                        listener.onLookupFailed(message);
                    }
                });
            }
        }, "geoapify-autocomplete").start();
    }

    @NonNull
    private static String fetch(@NonNull String url) throws Exception {
        Request request = new Request.Builder().url(url).build();
        try (Response response = HTTP.newCall(request).execute()) {
            ResponseBody body = response.body();
            String json = body == null ? "" : body.string();
            if (!response.isSuccessful()) {
                throw new IllegalStateException(GeoapifyErrors.httpFailure(response.code()));
            }
            return json;
        }
    }
}
