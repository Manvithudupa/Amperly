import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
}

// Keys are read from local.properties (which is gitignored) or from environment
// variables of the same name. Nothing here is committed.
//
//   MAPS_API_KEY               - Google Maps Android SDK key. Optional: without it the
//                                map panel shows an explanatory card and navigation is
//                                handed off to the phone's maps app through an intent.
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

val mapsApiKey: String = secret("MAPS_API_KEY")

val supabaseUrl: String = secret("SUPABASE_URL")
val supabasePublishableKey: String = secret("SUPABASE_PUBLISHABLE_KEY")

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

android {
    namespace = "com.amperly.app"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.amperly.app"
        minSdk = 24
        targetSdk = 35
        versionCode = 2
        versionName = "1.1"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
        buildConfigField("String", "MAPS_API_KEY", "\"$mapsApiKey\"")
        buildConfigField("boolean", "MAPS_ENABLED", (mapsApiKey.isNotEmpty()).toString())

        buildConfigField("String", "SUPABASE_URL", "\"$supabaseUrl\"")
        buildConfigField("String", "SUPABASE_PUBLISHABLE_KEY", "\"$supabasePublishableKey\"")
        buildConfigField("boolean", "SUPABASE_ENABLED", supabaseEnabled.toString())
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
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

    // Location & Maps Services
    implementation("com.google.android.gms:play-services-location:21.2.0")
    implementation("com.google.android.gms:play-services-maps:18.2.0")

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
