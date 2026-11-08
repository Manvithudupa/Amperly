package com.amperly.app;

import androidx.annotation.NonNull;

import com.amperly.app.core.security.NativeSessionBridge;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * The phone surface: Flutter renders everything the driver sees on the handset.
 *
 * <p>Android Auto deliberately does not go through this activity. The car host is a
 * {@link com.amperly.app.car.AmperlyCarAppService} and stays native Java because the Car App
 * Library draws its own templates and has no Flutter embedding path.
 *
 * <p>The build settings are already injected into {@link BuildConfig} for the Java side, so they
 * are handed to Dart over a channel instead of requiring a second copy in a Dart defines file.
 * Only the publishable Supabase key is exposed; a secret key never reaches this method.
 */
public class FlutterPhoneActivity extends FlutterActivity {

    private static final String CONFIG_CHANNEL = "com.amperly.app/native";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Flutter's Supabase storage is routed into the same Keystore-backed
        // session store the Java car service reads.
        NativeSessionBridge.attach(this, flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CONFIG_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (!"getConfig".equals(call.method)) {
                        result.notImplemented();
                        return;
                    }
                    Map<String, String> config = new HashMap<>();
                    config.put("SUPABASE_URL", BuildConfig.SUPABASE_URL);
                    config.put("SUPABASE_PUBLISHABLE_KEY", BuildConfig.SUPABASE_PUBLISHABLE_KEY);
                    config.put("GEOAPIFY_API_KEY", BuildConfig.GEOAPIFY_API_KEY);
                    config.put("MAP_STYLE_URL", BuildConfig.MAP_STYLE_URL);
                    config.put("APP_VERSION", BuildConfig.VERSION_NAME);
                    result.success(config);
                });
    }

    @Override
    public void cleanUpFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        NativeSessionBridge.detach(flutterEngine);
        super.cleanUpFlutterEngine(flutterEngine);
    }
}
