package com.amperly.app.core.map;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.util.LruCache;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * A map that draws OpenStreetMap raster tiles.
 *
 * <p>Deliberately dependency-free: the tiles are plain 256&times;256 PNGs fetched over the OkHttp
 * client the app already ships, projected with the standard Web Mercator formula and drawn onto a
 * {@link Canvas}. That means no API key, no billing account, no proprietary SDK and one less
 * library in the APK, which is the whole reason the map is here instead of Google Maps.
 *
 * <p>Point it at a different tile server with {@code OSM_TILE_URL} in {@code local.properties};
 * the URL is an OSM-style template such as {@code https://tiles.example.org/{z}/{x}/{y}.png}.
 *
 * <p>Tiles are cached in memory and on disk, so a station list opened once keeps working offline.
 */
public class OsmTileMapView extends View {

    /** A charger (or any point) to draw on the map. */
    public static class Pin {
        public final double latitude;
        public final double longitude;
        public final String title;
        public final int fillColor;
        public final int strokeColor;

        public Pin(double latitude, double longitude, @Nullable String title, int fillColor,
                   int strokeColor) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.title = title == null ? "" : title;
            this.fillColor = fillColor;
            this.strokeColor = strokeColor;
        }
    }

    public interface PinTap {
        void onPinTap(@NonNull Pin pin);
    }

    /** Reports where the user touched, in geographic terms. */
    public interface MapTap {
        void onTap(double latitude, double longitude);
    }

    private static final int TILE_SIZE = 256;
    private static final int MIN_ZOOM = 3;
    private static final int MAX_ZOOM = 18;
    private static final String DEFAULT_TILE_URL =
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
    private static final String DISK_CACHE_DIR = "osm-tiles";
    private static final long DISK_CACHE_MAX_BYTES = 64L * 1024L * 1024L;

    /** Two downloads at a time is plenty for a phone-sized viewport. */
    private static final ExecutorService FETCHER = Executors.newFixedThreadPool(3);
    private static final OkHttpClient HTTP = new OkHttpClient();
    private static final LruCache<String, Bitmap> MEMORY_CACHE =
            new LruCache<String, Bitmap>(9 * 1024 * 1024) {
                @Override
                protected int sizeOf(@NonNull String key, @NonNull Bitmap value) {
                    return value.getByteCount();
                }
            };

    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private final Set<String> inFlight = new HashSet<>();
    private final List<Pin> pins = new ArrayList<>();
    private final List<double[]> route = new ArrayList<>();
    private final List<Pin> hitOrder = new ArrayList<>();
    private final List<float[]> hitPoints = new ArrayList<>();

    private final Paint tilePaint = new Paint(Paint.FILTER_BITMAP_FLAG);
    private final Paint placeholderPaint = new Paint();
    private final Paint pinPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint pinStrokePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint routePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint creditPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
    private final Paint creditBackgroundPaint = new Paint();
    private final Path routePath = new Path();

    private double centerLat = 12.2958;
    private double centerLng = 76.6394;
    private float zoom = 12f;
    private boolean hasInitialCamera = false;

    private final GestureDetector gestures;
    private final ScaleGestureDetector scaleGestures;

    @Nullable
    private PinTap pinTap;
    @Nullable
    private MapTap mapTap;
    private boolean interactive = true;

    public OsmTileMapView(Context context) {
        this(context, null);
    }

    public OsmTileMapView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        placeholderPaint.setColor(Color.parseColor("#DCE5E0"));
        pinStrokePaint.setStyle(Paint.Style.STROKE);
        routePaint.setStyle(Paint.Style.STROKE);
        routePaint.setStrokeCap(Paint.Cap.ROUND);
        routePaint.setStrokeJoin(Paint.Join.ROUND);
        routePaint.setColor(Color.parseColor("#1B6FE3"));
        creditPaint.setColor(Color.parseColor("#3A3A3A"));
        creditPaint.setTextSize(getResources().getDisplayMetrics().scaledDensity * 10f);
        creditBackgroundPaint.setColor(Color.argb(170, 255, 255, 255));

        gestures = new GestureDetector(context, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onDown(@NonNull MotionEvent e) {
                return interactive;
            }

            @Override
            public boolean onScroll(@NonNull MotionEvent down, @NonNull MotionEvent move,
                                    float distanceX, float distanceY) {
                if (!interactive) {
                    return false;
                }
                pan(distanceX, distanceY);
                return true;
            }

            @Override
            public boolean onDoubleTap(@NonNull MotionEvent e) {
                if (!interactive) {
                    return false;
                }
                zoomBy(1f, e.getX(), e.getY());
                return true;
            }

            @Override
            public boolean onSingleTapConfirmed(@NonNull MotionEvent e) {
                if (!interactive) {
                    return false;
                }
                Pin hit = pinAt(e.getX(), e.getY());
                if (hit != null && pinTap != null) {
                    pinTap.onPinTap(hit);
                }
                if (mapTap != null) {
                    double[] point = screenToLatLng(e.getX(), e.getY());
                    mapTap.onTap(point[0], point[1]);
                }
                return hit != null;
            }
        });

        scaleGestures = new ScaleGestureDetector(context,
                new ScaleGestureDetector.SimpleOnScaleGestureListener() {
                    @Override
                    public boolean onScale(@NonNull ScaleGestureDetector detector) {
                        if (!interactive || detector.getScaleFactor() <= 0f) {
                            return false;
                        }
                        zoomBy((float) (Math.log(detector.getScaleFactor()) / Math.log(2d)),
                                detector.getFocusX(), detector.getFocusY());
                        return true;
                    }
                });
    }

    // ------------------------------------------------------------------ camera

    public void setPinTapListener(@Nullable PinTap listener) {
        this.pinTap = listener;
    }

    public void setMapTapListener(@Nullable MapTap listener) {
        this.mapTap = listener;
    }

    /** Turns off drag and zoom, for a small read-only preview panel. */
    public void setInteractive(boolean interactive) {
        this.interactive = interactive;
    }

    public void setCamera(double latitude, double longitude, float zoom) {
        this.centerLat = latitude;
        this.centerLng = longitude;
        this.zoom = clampZoom(zoom);
        hasInitialCamera = true;
        invalidate();
    }

    /**
     * Frames every point so all of them are visible, with a little breathing room. Falls back to a
     * sensible zoom for a single point or a degenerate spread.
     */
    public void fitTo(double north, double south, double east, double west, float fallbackZoom) {
        if (hasInitialCamera || getWidth() == 0 || getHeight() == 0
                || north <= south || east <= west) {
            if (!hasInitialCamera) {
                setCamera((north + south) / 2d, (east + west) / 2d, fallbackZoom);
            }
            return;
        }
        double centerLatitude = (north + south) / 2d;
        double centerLongitude = (east + west) / 2d;
        float best = fallbackZoom;
        for (int z = MAX_ZOOM; z >= MIN_ZOOM; z--) {
            double spanY = Math.abs(worldY(north, z) - worldY(south, z));
            double spanX = Math.abs(worldX(east, z) - worldX(west, z));
            if (spanY <= getHeight() * 0.82d && spanX <= getWidth() * 0.82d) {
                best = z;
                break;
            }
        }
        setCamera(centerLatitude, centerLongitude, best);
    }

    private void pan(float distanceX, float distanceY) {
        double scale = TILE_SIZE * Math.pow(2d, zoom);
        double worldX = worldX(centerLng, zoom) - distanceX;
        double worldY = worldY(centerLat, zoom) - distanceY;
        centerLng = longitudeAt(worldX, scale);
        centerLat = latitudeAt(worldY, scale);
        clampCenter();
        invalidate();
    }

    /** Zooms while keeping the point under the fingers where it is. */
    private void zoomBy(float deltaZoom, float focusX, float focusY) {
        if (deltaZoom == 0f) {
            return;
        }
        float target = clampZoom(zoom + deltaZoom);
        if (target == zoom) {
            return;
        }
        // The geographic point under the focus stays fixed: offset from the centre scales with zoom.
        double factor = Math.pow(2d, target - zoom);
        double worldCenterX = worldX(centerLng, zoom);
        double worldCenterY = worldY(centerLat, zoom);
        double focusWorldX = worldCenterX + (focusX - getWidth() / 2d);
        double focusWorldY = worldCenterY + (focusY - getHeight() / 2d);
        double newCenterX = focusWorldX - (focusX - getWidth() / 2d) * factor;
        double newCenterY = focusWorldY - (focusY - getHeight() / 2d) * factor;

        zoom = target;
        double scale = TILE_SIZE * Math.pow(2d, zoom);
        centerLng = longitudeAt(newCenterX, scale);
        centerLat = latitudeAt(newCenterY, scale);
        clampCenter();
        invalidate();
    }

    private float clampZoom(float value) {
        return Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, value));
    }

    private void clampCenter() {
        centerLat = Math.max(-85d, Math.min(85d, centerLat));
        while (centerLng > 180d) {
            centerLng -= 360d;
        }
        while (centerLng < -180d) {
            centerLng += 360d;
        }
    }

    // ------------------------------------------------------------------ content

    public void clearContent() {
        pins.clear();
        route.clear();
        invalidate();
    }

    public void setPins(@NonNull List<Pin> newPins) {
        pins.clear();
        pins.addAll(newPins);
        invalidate();
    }

    public void setRoute(@NonNull List<double[]> points) {
        route.clear();
        route.addAll(points);
        invalidate();
    }

    public boolean isEmpty() {
        return pins.isEmpty();
    }

    // --------------------------------------------------------------------- draw

    @Override
    protected void onDraw(@NonNull Canvas canvas) {
        super.onDraw(canvas);

        int width = getWidth();
        int height = getHeight();
        if (width <= 0 || height <= 0) {
            return;
        }

        float tileScale = (float) Math.pow(2d, zoom - Math.floor(zoom));
        int tileZoom = Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, (int) Math.floor(zoom)));
        float drawnTileSize = TILE_SIZE * tileScale;
        double scale = TILE_SIZE * Math.pow(2d, zoom);

        double centerWorldX = worldX(centerLng, zoom);
        double centerWorldY = worldY(centerLat, zoom);
        double originX = centerWorldX - width / 2d;
        double originY = centerWorldY - height / 2d;

        int tileCount = 1 << tileZoom;
        int firstX = (int) Math.floor(originX / drawnTileSize);
        int firstY = (int) Math.floor(originY / drawnTileSize);
        int lastX = (int) Math.floor((originX + width) / drawnTileSize);
        int lastY = (int) Math.floor((originY + height) / drawnTileSize);

        Rect source = new Rect(0, 0, TILE_SIZE, TILE_SIZE);
        RectF destination = new RectF();
        for (int tileX = firstX; tileX <= lastX; tileX++) {
            for (int tileY = firstY; tileY <= lastY; tileY++) {
                if (tileY < 0 || tileY >= tileCount) {
                    continue;
                }
                int wrappedX = ((tileX % tileCount) + tileCount) % tileCount;
                float left = (float) (tileX * drawnTileSize - originX);
                float top = (float) (tileY * drawnTileSize - originY);
                destination.set(left, top, left + drawnTileSize, top + drawnTileSize);

                Bitmap tile = bitmapFor(tileZoom, wrappedX, tileY);
                if (tile != null && !tile.isRecycled()) {
                    canvas.drawBitmap(tile, source, destination, tilePaint);
                } else {
                    canvas.drawRect(destination, placeholderPaint);
                }
            }
        }

        drawRoute(canvas, originX, originY, scale);
        drawPins(canvas, originX, originY, scale);
        drawCredit(canvas, width, height);
    }

    private void drawRoute(Canvas canvas, double originX, double originY, double scale) {
        if (route.size() < 2) {
            return;
        }
        routePaint.setStrokeWidth(getResources().getDisplayMetrics().density * 4f);
        routePath.reset();
        boolean started = false;
        for (double[] point : route) {
            float x = (float) (worldX(point[1], zoom) - originX);
            float y = (float) (worldY(point[0], zoom) - originY);
            if (!started) {
                routePath.moveTo(x, y);
                started = true;
            } else {
                routePath.lineTo(x, y);
            }
        }
        canvas.drawPath(routePath, routePaint);
    }

    private void drawPins(Canvas canvas, double originX, double originY, double scale) {
        hitOrder.clear();
        hitPoints.clear();
        float density = getResources().getDisplayMetrics().density;
        float radius = 9f * density;
        float stroke = 3f * density;
        pinStrokePaint.setStrokeWidth(stroke);

        for (Pin pin : pins) {
            float x = (float) (worldX(pin.longitude, zoom) - originX);
            float y = (float) (worldY(pin.latitude, zoom) - originY);
            if (x < -radius || y < -radius || x > getWidth() + radius || y > getHeight() + radius) {
                // Keep off-screen pins hit-testable only if they are near the edge.
                if (x < -radius * 3 || y < -radius * 3
                        || x > getWidth() + radius * 3 || y > getHeight() + radius * 3) {
                    continue;
                }
            }
            pinPaint.setColor(pin.fillColor);
            pinStrokePaint.setColor(pin.strokeColor);
            canvas.drawCircle(x, y, radius, pinPaint);
            canvas.drawCircle(x, y, radius, pinStrokePaint);
            pinPaint.setColor(pin.strokeColor);
            canvas.drawCircle(x, y, radius * 0.35f, pinPaint);
            hitOrder.add(pin);
            hitPoints.add(new float[]{x, y});
        }
    }

    private void drawCredit(Canvas canvas, int width, int height) {
        String credit = "© OpenStreetMap contributors";
        float padding = 4f * getResources().getDisplayMetrics().density;
        float textWidth = creditPaint.measureText(credit);
        float textHeight = creditPaint.getTextSize();
        float left = width - textWidth - padding * 2f;
        float top = height - textHeight - padding * 2.5f;
        canvas.drawRect(left, top, width, height, creditBackgroundPaint);
        canvas.drawText(credit, left + padding, height - padding * 1.5f, creditPaint);
    }

    /** Screen pixels to a coordinate, using the camera the last draw used. */
    @NonNull
    private double[] screenToLatLng(float x, float y) {
        double scale = TILE_SIZE * Math.pow(2d, zoom);
        double originX = worldX(centerLng, zoom) - getWidth() / 2d;
        double originY = worldY(centerLat, zoom) - getHeight() / 2d;
        return new double[]{latitudeAt(originY + y, scale), longitudeAt(originX + x, scale)};
    }

    @Nullable
    private Pin pinAt(float x, float y) {
        float threshold = 32f * getResources().getDisplayMetrics().density;
        Pin best = null;
        float bestDistance = Float.MAX_VALUE;
        for (int i = 0; i < hitOrder.size(); i++) {
            float[] point = hitPoints.get(i);
            float dx = point[0] - x;
            float dy = point[1] - y;
            float distance = (float) Math.sqrt(dx * dx + dy * dy);
            if (distance < threshold && distance < bestDistance) {
                bestDistance = distance;
                best = hitOrder.get(i);
            }
        }
        return best;
    }

    // ------------------------------------------------------------------- tiles

    /** Memory cache, then disk cache, then a download; never blocks the main thread. */
    @Nullable
    private Bitmap bitmapFor(int zoom, int x, int y) {
        final String key = tileKey(zoom, x, y);
        Bitmap cached = MEMORY_CACHE.get(key);
        if (cached != null) {
            return cached;
        }
        synchronized (inFlight) {
            if (inFlight.contains(key)) {
                return null;
            }
            inFlight.add(key);
        }
        final File cachedFile = new File(tileDir(), key);
        if (cachedFile.isFile() && cachedFile.length() > 0) {
            Bitmap fromDisk = BitmapFactory.decodeFile(cachedFile.getAbsolutePath());
            if (fromDisk != null) {
                MEMORY_CACHE.put(key, fromDisk);
                synchronized (inFlight) {
                    inFlight.remove(key);
                }
                return fromDisk;
            }
        }

        FETCHER.execute(() -> {
            Bitmap bitmap = download(key);
            synchronized (inFlight) {
                inFlight.remove(key);
            }
            if (bitmap != null) {
                MEMORY_CACHE.put(key, bitmap);
            }
            mainHandler.post(() -> {
                if (isAttachedToWindow()) {
                    invalidate();
                }
            });
        });
        return null;
    }

    @Nullable
    private Bitmap download(String key) {
        String[] parts = key.split("_");
        if (parts.length != 3) {
            return null;
        }
        String url = tileUrl(parts[0], parts[1], parts[2]);
        Request request = new Request.Builder()
                .url(url)
                .header("User-Agent", MapTiles.userAgent())
                .build();
        try (Response response = HTTP.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                return null;
            }
            ResponseBody body = response.body();
            if (body == null) {
                return null;
            }
            byte[] bytes = body.bytes();
            Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
            if (bitmap == null) {
                return null;
            }
            writeToDisk(key, bytes);
            return bitmap;
        } catch (Exception e) {
            // A missing tile just leaves the placeholder in place; the map stays usable offline.
            return null;
        }
    }

    private void writeToDisk(String key, byte[] bytes) {
        try {
            File target = new File(tileDir(), key);
            try (FileOutputStream out = new FileOutputStream(target)) {
                out.write(bytes);
            }
        } catch (Exception ignored) {
        }
    }

    private String tileUrl(String z, String x, String y) {
        String template = MapTiles.tileUrlTemplate();
        return template.replace("{z}", z).replace("{x}", x).replace("{y}", y);
    }

    private static String tileKey(int zoom, int x, int y) {
        return zoom + "_" + x + "_" + y;
    }

    private File tileDir() {
        File dir = new File(getContext().getCacheDir(), DISK_CACHE_DIR);
        if (!dir.isDirectory()) {
            //noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
        }
        return dir;
    }

    /** Trims the tile cache so a long-lived install cannot grow without bound. */
    public static void pruneDiskCache(Context context) {
        try {
            File dir = new File(context.getCacheDir(), DISK_CACHE_DIR);
            File[] files = dir.listFiles();
            if (files == null) {
                return;
            }
            long total = 0;
            for (File file : files) {
                total += file.length();
            }
            if (total <= DISK_CACHE_MAX_BYTES) {
                return;
            }
            Arrays.sort(files, (a, b) -> Long.compare(a.lastModified(), b.lastModified()));
            for (File file : files) {
                if (total <= DISK_CACHE_MAX_BYTES) {
                    break;
                }
                total -= file.length();
                //noinspection ResultOfMethodCallIgnored
                file.delete();
            }
        } catch (Exception ignored) {
        }
    }

    // ------------------------------------------------------- projection helpers
    // The arithmetic lives in Mercator so it can be unit tested without a device.

    private static double worldX(double longitude, float zoom) {
        return Mercator.worldX(longitude, zoom);
    }

    private static double worldY(double latitude, float zoom) {
        return Mercator.worldY(latitude, zoom);
    }

    private static double longitudeAt(double worldX, double worldSize) {
        return worldX / worldSize * 360d - 180d;
    }

    private static double latitudeAt(double worldY, double worldSize) {
        double n = Math.PI - 2d * Math.PI * worldY / worldSize;
        return Math.toDegrees(Math.atan(Math.sinh(n)));
    }

    // ------------------------------------------------------------------- input

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (!interactive) {
            return super.onTouchEvent(event);
        }
        boolean handled = scaleGestures.onTouchEvent(event);
        handled = gestures.onTouchEvent(event) || handled;
        if (event.getActionMasked() == MotionEvent.ACTION_UP && handled) {
            performClick();
        }
        return handled || super.onTouchEvent(event);
    }

    @Override
    public boolean performClick() {
        super.performClick();
        return true;
    }

}
