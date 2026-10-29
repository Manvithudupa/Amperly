package com.amperly.app.car.screen;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.car.app.AppManager;
import androidx.car.app.CarContext;
import androidx.car.app.SurfaceCallback;
import androidx.car.app.SurfaceContainer;

import com.amperly.app.core.common.MapConfig;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * Paints a real map into the surface the car host hands to a map template.
 *
 * <p>The Car App Library draws none of the map itself: it hands the app a {@link Surface} and the
 * app is responsible for every pixel. MapLibre's Android SDK only renders inside an Android View,
 * which a car surface is not, so the glanceable map here is a Geoapify static map of the same
 * OSM-Bright style the phone draws. It is fetched once per trip/position change and painted in a
 * single pass, which keeps the car display cheap and reliable (no GL loop, no lifecycle races).
 *
 * <p>Markers are the recommended charger and the reachable chargers; the attribution is part of
 * the static image, as the Geoapify terms require.
 */
public final class CarMap implements SurfaceCallback {

    /** One marker on the static map. {@code color} is a {@code RRGGBB} value without '#'. */
    public static final class Pin {
        final double latitude;
        final double longitude;
        final String color;

        public Pin(double latitude, double longitude, @NonNull String color) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.color = color;
        }
    }

    private static final String STATIC_MAP = "https://api.geoapify.com/v1/staticmap";
    private static final int MAX_PINS = 6;
    private static final OkHttpClient HTTP = new OkHttpClient();
    private static final String COLOR_STATION = "0F5C4D";
    private static final String COLOR_DESTINATION = "B3261E";

    private final CarContext carContext;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final ExecutorService executor = Executors.newSingleThreadExecutor();
    private final Paint paint = new Paint(Paint.FILTER_BITMAP_FLAG);

    @Nullable private Surface surface;
    private int width;
    private int height;
    private double centerLat;
    private double centerLng;
    private int zoom = 12;
    private List<Pin> pins = new ArrayList<>();
    @Nullable private String renderedUrl;
    @Nullable private volatile Bitmap bitmap;
    private boolean started;

    public CarMap(@NonNull CarContext carContext) {
        this.carContext = carContext;
    }

    /** Registers for the surface. Safe to call more than once. */
    public void start() {
        if (started) {
            return;
        }
        started = true;
        carContext.getCarService(AppManager.class).setSurfaceCallback(this);
    }

    /** Releases the surface and stops pending fetches. */
    public void stop() {
        if (!started) {
            return;
        }
        started = false;
        try {
            carContext.getCarService(AppManager.class).setSurfaceCallback(null);
        } catch (RuntimeException ignored) {
            // The host already tore the session down.
        }
        executor.shutdownNow();
        surface = null;
    }

    /** Sets the view to draw and repaints when the surface is ready. */
    public void show(double latitude, double longitude, int zoom, @NonNull List<Pin> pins) {
        this.centerLat = latitude;
        this.centerLng = longitude;
        this.zoom = zoom;
        this.pins = pins;
        render();
    }

    /** Marks a charger with the app's primary colour. */
    @NonNull
    public static Pin station(double latitude, double longitude) {
        return new Pin(latitude, longitude, COLOR_STATION);
    }

    /** Marks the trip destination. */
    @NonNull
    public static Pin destination(double latitude, double longitude) {
        return new Pin(latitude, longitude, COLOR_DESTINATION);
    }

    // ------------------------------------------------------------- surface

    @Override
    public void onSurfaceAvailable(@NonNull SurfaceContainer container) {
        surface = container.getSurface();
        width = container.getWidth();
        height = container.getHeight();
        if (bitmap != null) {
            draw();
        } else {
            render();
        }
    }

    @Override
    public void onVisibleAreaChanged(@NonNull Rect visibleArea) {
        // The whole surface is visible; a static map does not need to react to the inset.
    }

    @Override
    public void onStableAreaChanged(@NonNull Rect stableArea) {
        // Same as above: the image is already scaled to the full surface.
    }

    @Override
    public void onSurfaceDestroyed(@NonNull SurfaceContainer container) {
        surface = null;
    }

    // ------------------------------------------------------------- painting

    private void render() {
        Surface current = surface;
        if (!started || current == null || !current.isValid() || width <= 0 || height <= 0) {
            return;
        }
        if (!MapConfig.isConfigured()) {
            return;
        }
        final String url = buildUrl();
        if (url.equals(renderedUrl) && bitmap != null) {
            draw();
            return;
        }
        renderedUrl = url;
        try {
            executor.execute(() -> {
                Bitmap loaded = download(url);
                if (loaded == null) {
                    return;
                }
                bitmap = loaded;
                mainHandler.post(this::draw);
            });
        } catch (RuntimeException ignored) {
            // The screen was destroyed between the check and the enqueue.
        }
    }

    private void draw() {
        Surface current = surface;
        Bitmap image = bitmap;
        if (current == null || image == null || !current.isValid() || width <= 0 || height <= 0) {
            return;
        }
        try {
            Canvas canvas = current.lockCanvas(null);
            if (canvas == null) {
                return;
            }
            try {
                canvas.drawColor(0xFF15171A);
                canvas.drawBitmap(image, null, new Rect(0, 0, width, height), paint);
            } finally {
                current.unlockCanvasAndPost(canvas);
            }
        } catch (RuntimeException ignored) {
            // The host removed the surface between the validity check and the lock.
        }
    }

    @NonNull
    private String buildUrl() {
        StringBuilder url = new StringBuilder(STATIC_MAP)
                .append("?style=osm-bright")
                .append("&width=").append(Math.max(320, width))
                .append("&height=").append(Math.max(240, height))
                .append("&center=lonlat:").append(coordinate(centerLng))
                .append(',').append(coordinate(centerLat))
                .append("&zoom=").append(zoom)
                .append("&attribution=default");

        int count = 0;
        for (Pin pin : pins) {
            if (count++ >= MAX_PINS) {
                break;
            }
            url.append(count == 1 ? "&marker=" : "|")
                    .append("lonlat:").append(coordinate(pin.longitude))
                    .append(',').append(coordinate(pin.latitude))
                    .append(";color:%23").append(pin.color)
                    .append(";size:medium");
        }
        return MapConfig.withKey(url.toString());
    }

    @Nullable
    private static Bitmap download(@NonNull String url) {
        try (Response response = HTTP.newCall(new Request.Builder().url(url).build()).execute()) {
            if (!response.isSuccessful()) {
                return null;
            }
            ResponseBody body = response.body();
            return body == null ? null : BitmapFactory.decodeStream(body.byteStream());
        } catch (Exception e) {
            return null;
        }
    }

    @NonNull
    private static String coordinate(double value) {
        return String.format(Locale.US, "%.6f", value);
    }
}
