package com.amperly.app.ui.dialog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.places.PlacesAutocomplete;
import com.amperly.app.ui.Ux;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;

/**
 * Address search in a dialog, for screens that need one place rather than a text field.
 *
 * <p>It is the same Geoapify autocomplete and the same suggestion row the rest of the app uses
 * ({@link PlacesAutocomplete}, {@code item_place_suggestion}); the dialog only gives it a
 * container. The chosen place already carries its address and coordinates, so the caller fills
 * both from one selection.
 */
public final class PlaceSearchDialog {

    public interface Listener {
        void onPlaceSelected(@NonNull PlacesAutocomplete.Selection selection);
    }

    private PlaceSearchDialog() {
    }

    public static void show(@NonNull Fragment host, @Nullable Listener listener) {
        Context context = host.getContext();
        if (context == null) {
            return;
        }
        if (!PlacesAutocomplete.isAvailable(context)) {
            // No key configured: say so instead of opening a search that cannot answer.
            Ux.error(host, context.getString(R.string.error_place_search));
            return;
        }

        View content = LayoutInflater.from(context).inflate(R.layout.dialog_place_search, null, false);
        MaterialAutoCompleteTextView field = content.findViewById(R.id.placeSearchEdit);

        AlertDialog dialog = new MaterialAlertDialogBuilder(context)
                .setTitle(R.string.host_place_search_title)
                .setView(content)
                .setNegativeButton(R.string.action_cancel, null)
                .create();
        PlacesAutocomplete.bind(context, field, new PlacesAutocomplete.Listener() {
            @Override
            public void onPlaceSelected(@NonNull PlacesAutocomplete.Selection selection) {
                dialog.dismiss();
                if (listener != null) {
                    listener.onPlaceSelected(selection);
                }
            }

            @Override
            public void onSelectionCleared() {
            }

            @Override
            public void onLookupFailed(@NonNull String message) {
                Ux.error(host, message);
            }
        });

        dialog.setOnShowListener(ignored -> {
            Ux.resizeForKeyboard(dialog);
            field.requestFocus();
        });
        dialog.show();
    }
}
