package com.amperly.app.car.screen;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.car.app.AppManager;
import androidx.car.app.CarContext;
import androidx.car.app.SurfaceCallback;
import androidx.car.app.SurfaceContainer;

import com.amperly.app.R;
import com.amperly.app.car.CarLocation;
import com.amperly.app.car.CarMapGeometry;
import com.amperly.app.car.CarMapUrl;
import com.amperly.app.core.common.MapConfig;

import java.util.ArrayList;
import java.util.Collections;
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
 * OSM-Bright style the phone draws.
 *
 * <p>The image is centred on the driver's real position, with the trip destination and reachable
 * chargers marked. The blue "you are here" marker is drawn on the canvas after the image, so it can
 * never be hidden by a station marker and it follows the newest fix without another network fetch.
 * A fetch happens only when the driver has moved more than 150 m, the visible content changed, or
 * the fit zoom changed — and never more than once every ten seconds.
 *
 * <p>When there is no map key, no fix, or the image cannot be downloaded, the surface says so in
 * words instead of showing a made-up location.
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
    private static final int COLOR_DRIVER = 0xFF1A73E8;
    private static final int COLOR_SURFACE = 0xFF15171A;

    private final CarContext carContext;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final Paint bitmapPaint = new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Paint driverFill = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint driverRing = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint bannerBackground = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint bannerText = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Rect visibleArea = new Rect();
    private boolean started;
    private final Runnable retryRunnable = () -> {
        if (started) {
            render();
        }
    };

    @Nullable private ExecutorService executor;
    @Nullable private Surface surface;
    private int width;
    private int height;

    private double centerLat;
    private double centerLng;
    private int zoom = 12;
    private boolean hasViewport;
    private List<Pin> pins = new ArrayList<>();
    @Nullable private CarLocation.Fix driver;
    @Nullable private String notice;

    @Nullable private volatile Bitmap bitmap;
    @Nullable private String renderedKey;
    private long lastFetchMs;
    private double lastFetchLat;
    private double lastFetchLng;
    private int lastFetchZoom = Integer.MIN_VALUE;
    private int generation;
    private boolean downloadFailed;

    public CarMap(@NonNull CarContext carContext) {
        this.carContext = carContext;
        driverFill.setStyle(Paint.Style.FILL);
        driverFill.setColor(COLOR_DRIVER);
        driverRing.setStyle(Paint.Style.FILL);
        driverRing.setColor(0xFFFFFFFF);
        bannerBackground.setStyle(Paint.Style.FILL);
        bannerBackground.setColor(0xE615171A);
        bannerText.setColor(0xFFF3F4F6);
        bannerText.setAntiAlias(true);
    }

    /** Registers for the surface. Safe to call more than once. */
    public void start() {
        if (started) {
            return;
        }
        started = true;
        try {
            carContext.getCarService(AppManager.class).setSurfaceCallback(this);
        } catch (RuntimeException e) {
            started = false;
        }
    }

    /** Releases the surface and stops pending fetches. A later {@link #start()} works again. */
    public void stop() {
        if (!started) {
            return;
        }
        started = false;
        generation++;
        mainHandler.removeCallbacks(retryRunnable);
        try {
            carContext.getCarService(AppManager.class).setSurfaceCallback(null);
        } catch (RuntimeException ignored) {
            // The host already tore the session down.
        }
        ExecutorService current = executor;
        executor = null;
        if (current != null) {
            current.shutdownNow();
        }
        surface = null;
    }

    /**
     * Sets what the map should show.
     *
     * @param driver the newest real fix, or null when there is none
     * @param pins   chargers and the destination
     * @param notice an honest line shown over the map, or null when the fix is live
     */
    public void show(@Nullable CarLocation.Fix driver, @NonNull List<Pin> pins,
                     @Nullable String notice) {
        this.driver = driver;
        this.pins = new ArrayList<>(pins);
        this.notice = notice;
        updateViewport();
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
        visibleArea.set(0, 0, width, height);
        updateViewport();
        render();
    }

    @Override
    public void onVisibleAreaChanged(@NonNull Rect area) {
        visibleArea.set(area);
        updateViewport();
        if (bitmap != null) {
            draw();
        }
        render();
    }

    @Override
    public void onStableAreaChanged(@NonNull Rect stableArea) {
        // The visible-area callback already drives both the marker position and the fit.
    }

    @Override
    public void onSurfaceDestroyed(@NonNull SurfaceContainer container) {
        surface = null;
        generation++;
        mainHandler.removeCallbacks(retryRunnable);
    }

    // ------------------------------------------------------------- viewport

    private void updateViewport() {
        boolean any = false;
        double minLat = 90;
        double maxLat = -90;
        double minLng = 180;
        double maxLng = -180;
        boolean driverIsUsable = driver != null
                && CarMapGeometry.isValidCoordinate(driver.latitude, driver.longitude);

        if (driverIsUsable) {
            any = true;
            minLat = Math.min(minLat, driver.latitude);
            maxLat = Math.max(maxLat, driver.latitude);
            minLng = Math.min(minLng, driver.longitude);
            maxLng = Math.max(maxLng, driver.longitude);
        }
        for (Pin pin : pins) {
            if (!CarMapGeometry.isValidCoordinate(pin.latitude, pin.longitude)) {
                continue;
            }
            any = true;
            minLat = Math.min(minLat, pin.latitude);
            maxLat = Math.max(maxLat, pin.latitude);
            minLng = Math.min(minLng, pin.longitude);
            maxLng = Math.max(maxLng, pin.longitude);
        }

        hasViewport = any;
        if (!any) {
            return;
        }

        if (driverIsUsable) {
            centerLat = driver.latitude;
            centerLng = driver.longitude;
        } else {
            double[] center = CarMapGeometry.centerOfBounds(minLat, minLng, maxLat, maxLng);
            centerLat = center[0];
            centerLng = center[1];
        }

        int usableWidth = visibleArea.width() > 0 ? visibleArea.width() : width;
        int usableHeight = visibleArea.height() > 0 ? visibleArea.height() : height;
        zoom = CarMapGeometry.zoomForBounds(minLat, minLng, maxLat, maxLng,
                usableWidth, usableHeight, Math.round(dp(40)));
        if (!driverIsUsable && minLat == maxLat && minLng == maxLng) {
            zoom = Math.max(zoom, 14);
        }
    }

    // ------------------------------------------------------------- fetching

    private void render() {
        Surface current = surface;
        if (!started || current == null || !current.isValid() || width <= 0 || height <= 0) {
            return;
        }
        if (!MapConfig.isConfigured() || !hasViewport) {
            draw();
            return;
        }

        String key = buildKey();
        boolean contentChanged = !key.equals(renderedKey);
        boolean needsImage = bitmap == null;
        double moved = lastFetchMs <= 0 ? 0
                : CarMapGeometry.distanceMeters(lastFetchLat, lastFetchLng, centerLat, centerLng);
        boolean zoomChanged = lastFetchZoom != zoom;
        long now = SystemClock.elapsedRealtime();

        if (lastFetchMs > 0 && !CarMapGeometry.shouldRefetch(now, lastFetchMs, moved,
                contentChanged || downloadFailed || needsImage, zoomChanged)) {
            if (contentChanged || downloadFailed || needsImage
                    || moved > CarMapGeometry.REFETCH_DISTANCE_METERS) {
                scheduleRetry(now);
            }
            draw();
            return;
        }

        lastFetchMs = now;
        lastFetchLat = centerLat;
        lastFetchLng = centerLng;
        lastFetchZoom = zoom;
        renderedKey = key;
        final int requestId = ++generation;
        final String url = buildUrl();

        try {
            executor().execute(() -> {
                final Bitmap loaded = download(url);
                mainHandler.post(() -> {
                    if (requestId != generation || !started) {
                        return;
                    }
                    if (loaded != null) {
                        bitmap = loaded;
                        downloadFailed = false;
                    } else {
                        downloadFailed = true;
                    }
                    draw();
                    if (loaded == null) {
                        scheduleRetry(SystemClock.elapsedRealtime());
                    }
                });
            });
        } catch (RuntimeException e) {
            downloadFailed = true;
            draw();
            scheduleRetry(SystemClock.elapsedRealtime());
        }
    }

    private void scheduleRetry(long now) {
        long wait = Math.max(0,
                CarMapGeometry.MIN_REFETCH_INTERVAL_MS - Math.max(0, now - lastFetchMs));
        mainHandler.removeCallbacks(retryRunnable);
        mainHandler.postDelayed(retryRunnable, wait + 100L);
    }

    @NonNull
    private ExecutorService executor() {
        ExecutorService current = executor;
        if (current == null || current.isShutdown()) {
            current = Executors.newSingleThreadExecutor();
            executor = current;
        }
        return current;
    }

    @NonNull
    private String buildKey() {
        // The centre is deliberately excluded: a small move must not refetch. Only the pins, the
        // zoom (checked separately) and the surface size change what the image contains.
        StringBuilder key = new StringBuilder()
                .append(width).append('x').append(height).append(';');
        for (Pin pin : pins) {
            key.append(String.format(Locale.US, "%.6f,%.6f,", pin.latitude, pin.longitude))
                    .append(pin.color).append(';');
        }
        return key.toString();
    }

    @NonNull
    private String buildUrl() {
        StringBuilder url = new StringBuilder(STATIC_MAP)
                .append("?style=osm-bright")
                .append("&width=").append(Math.max(320, width))
                .append("&height=").append(Math.max(240, height))
                .append("&center=lonlat:").append(CarMapUrl.coordinate(centerLng))
                .append(',').append(CarMapUrl.coordinate(centerLat))
                .append("&zoom=").append(zoom)
                .append("&attribution=default");

        int count = 0;
        for (Pin pin : pins) {
            if (count >= MAX_PINS || !CarMapGeometry.isValidCoordinate(pin.latitude, pin.longitude)) {
                continue;
            }
            url.append(count == 0 ? "&marker=" : "|")
                    .append(CarMapUrl.marker(pin.latitude, pin.longitude, pin.color));
            count++;
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

    // ------------------------------------------------------------- painting

    private void draw() {
        Surface current = surface;
        if (current == null || !current.isValid() || width <= 0 || height <= 0) {
            return;
        }
        try {
            Canvas canvas = current.lockCanvas(null);
            if (canvas == null) {
                return;
            }
            try {
                canvas.drawColor(COLOR_SURFACE);
                Bitmap image = bitmap;
                if (image != null) {
                    canvas.drawBitmap(image, null, new Rect(0, 0, width, height), bitmapPaint);
                }
                if (image != null && driver != null) {
                    drawDriver(canvas);
                }
                drawNotice(canvas, image != null);
            } finally {
                current.unlockCanvasAndPost(canvas);
            }
        } catch (RuntimeException ignored) {
            // The host removed the surface between the validity check and the lock.
        }
    }

    private void drawDriver(@NonNull Canvas canvas) {
        // The bitmap is centred on the position used for the last request. Until the next request
        // the driver marker is projected from that point, so a move smaller than the 150 m refetch
        // threshold still appears in the right place.
        double baseLat = lastFetchMs > 0 ? lastFetchLat : centerLat;
        double baseLng = lastFetchMs > 0 ? lastFetchLng : centerLng;
        double[] offset = driver == null ? new double[]{0, 0}
                : CarMapGeometry.projectOffsetPixels(baseLat, baseLng, driver.latitude,
                driver.longitude, zoom);
        float cx = width / 2f + (float) offset[0];
        float cy = height / 2f + (float) offset[1];
        float radius = dp(8);
        canvas.drawCircle(cx, cy, radius + dp(3), driverRing);
        canvas.drawCircle(cx, cy, radius, driverFill);

        if (driver != null && driver.hasBearing) {
            Path heading = new Path();
            float tip = radius + dp(9);
            heading.moveTo(cx, cy - tip);
            heading.lineTo(cx - dp(4), cy - radius);
            heading.lineTo(cx + dp(4), cy - radius);
            heading.close();
            canvas.save();
            canvas.rotate(driver.bearingDegrees, cx, cy);
            canvas.drawPath(heading, driverFill);
            canvas.restore();
        }
    }

    private void drawNotice(@NonNull Canvas canvas, boolean hasImage) {
        String text = notice;
        if (!MapConfig.isConfigured()) {
            text = carContext.getString(R.string.car_map_unavailable);
        } else if (!hasViewport) {
            text = text == null ? carContext.getString(R.string.car_map_waiting_location) : text;
        } else if (text == null && driver == null) {
            text = carContext.getString(R.string.car_map_waiting_location);
        } else if (text == null && downloadFailed && !hasImage) {
            text = carContext.getString(R.string.car_map_offline);
        }
        if (text == null) {
            return;
        }

        float textSize = dp(16);
        int maxWidth = Math.max(1, width - Math.round(dp(32)));
        List<String> lines = wrap(text, maxWidth, textSize);
        float lineHeight = textSize * 1.25f;
        float blockHeight = lines.size() * lineHeight;

        if (!hasImage) {
            bannerText.setTextSize(textSize);
            bannerText.setTextAlign(Paint.Align.CENTER);
            float startY = height / 2f - blockHeight / 2f + lineHeight;
            for (int i = 0; i < lines.size(); i++) {
                canvas.drawText(lines.get(i), width / 2f, startY + i * lineHeight, bannerText);
            }
            return;
        }

        float padding = dp(12);
        float top = height - blockHeight - padding * 2f;
        canvas.drawRect(0, top, width, height, bannerBackground);
        bannerText.setTextSize(textSize);
        bannerText.setTextAlign(Paint.Align.LEFT);
        float startY = top + padding + lineHeight;
        for (int i = 0; i < lines.size(); i++) {
            canvas.drawText(lines.get(i), padding, startY + i * lineHeight, bannerText);
        }
    }

    @NonNull
    private List<String> wrap(@NonNull String text, int maxWidth, float textSize) {
        bannerText.setTextSize(textSize);
        List<String> lines = new ArrayList<>();
        String remaining = text.trim();
        while (!remaining.isEmpty() && lines.size() < 3) {
            int fit = bannerText.breakText(remaining, true, maxWidth, null);
            if (fit <= 0) {
                fit = 1;
            }
            if (fit < remaining.length()) {
                int space = remaining.lastIndexOf(' ', fit);
                if (space > 0) {
                    fit = space;
                }
            }
            lines.add(remaining.substring(0, fit).trim());
            remaining = remaining.substring(fit).trim();
        }
        if (!remaining.isEmpty() && !lines.isEmpty()) {
            lines.set(lines.size() - 1, lines.get(lines.size() - 1) + "…");
        }
        return Collections.unmodifiableList(lines);
    }

    private float dp(float value) {
        return value * carContext.getResources().getDisplayMetrics().density;
    }

}
