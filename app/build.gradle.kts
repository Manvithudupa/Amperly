import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
}

// Keys are read from local.properties (which is gitignored) or from environment
// variables of the same name. Nothing here is committed.
//
//   GOOGLE_MAPS_API_KEY        - required for the map, Place autocomplete and road routing.
//                                One Google Cloud Android key with the "Maps SDK for
//                                Android", "Places API" and "Directions API" enabled,
//                                restricted to this package name + signing SHA-1. It is
//                                injected through BuildConfig and the manifest placeholder
//                                below and is never written into Java or XML by hand.
//   SUPABASE_URL               - your project URL, https://<ref>.supabase.co
//   SUPABASE_PUBLISHABLE_KEY   - the public sb_publishable_... (formerly "anon") key.
//                                Safe to ship ONLY because every table has RLS enabled.
//                                NEVER put a sb_secret_/service_role key here.
//
// Without the Supabase pair the app runs fully on-device against Room and the local
// seeder, exactly as it did before the backend existed.
val localProperties = Properties().apply {
    val file = rootProject.file("local.properties")
    if (file.exists()) {
        file.inputStream().use { load(it) }
    }
}

fun secret(name: String): String =
    (localProperties.getProperty(name) ?: System.getenv(name) ?: "").trim()

// Google Maps Platform key. The same value feeds BuildConfig (for the Directions and Place
// autocomplete web calls) and the manifest placeholder (for the Maps SDK renderer), so a
// single entry in local.properties configures the whole map experience.
val googleMapsApiKey: String = secret("GOOGLE_MAPS_API_KEY")
val googleMapsEnabled: Boolean = googleMapsApiKey.isNotEmpty()

if (!googleMapsEnabled) {
    logger.warn(
        "Amperly: no GOOGLE_MAPS_API_KEY set, so the map, Place autocomplete and road routing " +
            "are disabled and the screens show an actionable setup notice instead of a blank map. " +
            "See README section 6."
    )
}

val supabaseUrl: String = secret("SUPABASE_URL")
val supabasePublishableKey: String = secret("SUPABASE_PUBLISHABLE_KEY")

// Release signing. Everything here is gitignored for the same reason the Supabase key is: a
// keystore and its passwords must never enter version control. Without it the release build still
// works, but it produces an unsigned APK that no device will install.
val keystoreFilePath: String = secret("KEYSTORE_FILE")
val keystorePassword: String = secret("KEYSTORE_PASSWORD")
val keystoreAlias: String = secret("KEY_ALIAS")
val keystoreKeyPassword: String = secret("KEY_PASSWORD")
val releaseKeystore: File? = keystoreFilePath.takeIf { it.isNotEmpty() }
    ?.let { rootProject.file(it) }
    ?.takeIf { it.exists() }

if (keystoreFilePath.isNotEmpty() && releaseKeystore == null) {
    logger.warn(
        "Amperly: KEYSTORE_FILE points at a file that does not exist (${rootProject.file(keystoreFilePath)}). " +
            "The release APK will be unsigned and therefore not installable."
    )
}

// Both halves are required. A URL with no key (or the reverse) is a half-finished
// setup, and silently half-enabling sync would be worse than staying offline.
val supabaseEnabled: Boolean = supabaseUrl.isNotEmpty() && supabasePublishableKey.isNotEmpty()

if (supabaseUrl.isNotEmpty() != supabasePublishableKey.isNotEmpty()) {
    logger.warn(
        "Amperly: set BOTH SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY in local.properties " +
            "(or neither). Supabase sync stays off until both are present."
    )
}
if (supabasePublishableKey.startsWith("sb_secret_") || supabasePublishableKey.contains("service_role")) {
    throw GradleException(
        "SUPABASE_PUBLISHABLE_KEY looks like a SECRET key. That bypasses Row Level " +
            "Security entirely and must never ship in an app. Use the sb_publishable_ key."
    )
}

if (releaseKeystore == null) {
    logger.warn(
        "Amperly: no release keystore configured, so assembleRelease will emit an unsigned APK. " +
            "Set KEYSTORE_FILE, KEYSTORE_PASSWORD, KEY_ALIAS and KEY_PASSWORD in local.properties. " +
            "See README section 6."
    )
}

android {
    namespace = "com.amperly.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.amperly.app"
        minSdk = 24
        targetSdk = 35
        versionCode = 9
        versionName = "3.1.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // Google Maps Platform. The key is injected, never hard-coded: BuildConfig for the
        // in-app web calls and a manifest placeholder for the Maps SDK meta-data entry.
        buildConfigField("String", "GOOGLE_MAPS_API_KEY", "\"$googleMapsApiKey\"")
        buildConfigField("boolean", "GOOGLE_MAPS_ENABLED", googleMapsEnabled.toString())
        manifestPlaceholders["googleMapsApiKey"] = googleMapsApiKey

        buildConfigField("String", "SUPABASE_URL", "\"$supabaseUrl\"")
        buildConfigField("String", "SUPABASE_PUBLISHABLE_KEY", "\"$supabasePublishableKey\"")
        buildConfigField("boolean", "SUPABASE_ENABLED", supabaseEnabled.toString())
    }

    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = releaseKeystore
                storePassword = keystorePassword
                keyAlias = keystoreAlias
                keyPassword = keystoreKeyPassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfigs.findByName("release")?.let { signingConfig = it }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    buildFeatures {
        viewBinding = true
        buildConfig = true
    }
}

dependencies {
    implementation(libs.appcompat)
    implementation(libs.material)
    implementation(libs.constraintlayout)
    implementation(libs.activity.ktx)

    // Android for Cars App Library
    implementation("androidx.car.app:app:1.4.0")

    // Room Database
    implementation("androidx.room:room-runtime:2.6.1")
    annotationProcessor("androidx.room:room-compiler:2.6.1")

    // Encrypted storage for the Supabase session tokens (Keystore-backed AES-256-GCM).
    // A plain SharedPreferences file is readable from a backup or a rooted device; these
    // tokens are bearer credentials, so they are encrypted at rest instead.
    implementation("androidx.security:security-crypto:1.1.0-alpha06")

    // Lists & lifecycle-aware UI
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("androidx.core:core:1.13.1")
    implementation("androidx.fragment:fragment:1.6.2")

    // HTTP for the Supabase (PostgREST + GoTrue) client
    implementation(libs.retrofit)
    implementation(libs.retrofitgson)
    implementation(libs.okhttp)
    implementation(libs.okhttplogging)
    implementation(libs.gson)

    // Location fixes. Play Services is still the cheapest, most battery-friendly way to
    // get a position on the devices that ship it.
    implementation("com.google.android.gms:play-services-location:21.2.0")

    // Maps: the production map is the Google Maps SDK for Android (core/map/MapPanel), and
    // destinations are found with Google Place autocomplete (core/places/PlacesAutocomplete).
    // Both use the key injected above.
    implementation(libs.playservicesmaps)
    implementation(libs.places)

    // Navigation & Lifecycle Components
    implementation("androidx.navigation:navigation-fragment:2.7.7")
    implementation("androidx.navigation:navigation-ui:2.7.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel:2.7.0")
    implementation("androidx.lifecycle:lifecycle-livedata:2.7.0")
    implementation("androidx.swiperefreshlayout:swiperefreshlayout:1.1.0")

    // QR Code generation
    implementation("com.google.zxing:core:3.5.3")

    // Testing
    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)
}
