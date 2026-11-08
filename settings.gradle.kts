pluginManagement {
    // pluginManagement is compiled before the rest of the settings script, so
    // the SDK path is read here, with fully qualified types for that early stage.
    val flutterLocalProperties = file("flutter_app/.android/local.properties")
    if (flutterLocalProperties.exists()) {
        val flutterProperties = java.util.Properties()
        flutterLocalProperties.inputStream().use { input ->
            flutterProperties.load(input)
        }
        flutterProperties.getProperty("flutter.sdk")?.let { flutterSdk ->
            includeBuild("$flutterSdk/packages/flutter_tools/gradle")
        }
    }
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}
dependencyResolutionManagement {
    // The generated Flutter module declares its own Google/Maven repositories.
    // Settings repositories remain authoritative; project declarations are ignored.
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter engine artifacts (libflutter.so, libapp.so and the embedding
        // jars) are served from here, not Maven Central. Settings repositories
        // are authoritative in this build, so this has to be declared here.
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "Amperly"
include(":app")

// Adds :flutter plus the native plugin subprojects (secure storage, app links,
// path provider, URL launcher). The Java seed is required for settings scripts.
apply(from = file("flutter_module.gradle"))
