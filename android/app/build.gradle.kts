import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "sp.math.puzzle.games.crossmathpuzzle.play"
    // flutter_local_notifications + AndroidX core 1.19 require compiling against API 37.
    compileSdk = maxOf(flutter.compileSdkVersion, 37)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "sp.math.puzzle.games.crossmathpuzzle.play"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        multiDexEnabled = true
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---------------------------------------------------------------- Release signing
    // Values come from android/key.properties (copy android/key.properties-sample), or from
    // environment variables for CI: CM_STORE_FILE, CM_STORE_PASSWORD, CM_KEY_ALIAS, CM_KEY_PASSWORD.
    // storeFile may be absolute (spaces are fine) or relative to android/app/ or android/.
    val keyPropertiesFile = rootProject.file("key.properties")
    val keyProperties = Properties().apply {
        if (keyPropertiesFile.exists()) keyPropertiesFile.reader(Charsets.UTF_8).use { load(it) }
    }
    fun signingValue(key: String, env: String): String? =
        (keyProperties.getProperty(key) ?: System.getenv(env))?.trim()?.takeIf { it.isNotEmpty() }

    val storeFilePath = signingValue("storeFile", "CM_STORE_FILE")
    val storePasswordValue = signingValue("storePassword", "CM_STORE_PASSWORD")
    val keyAliasValue = signingValue("keyAlias", "CM_KEY_ALIAS")
    val keyPasswordValue = signingValue("keyPassword", "CM_KEY_PASSWORD") ?: storePasswordValue
    val hasReleaseKey = listOf(storeFilePath, storePasswordValue, keyAliasValue).all { it != null }

    // Building an app bundle (bundleRelease) means uploading to Google Play: require the real key.
    val buildingBundle = gradle.startParameter.taskNames.any { it.contains("bundle", ignoreCase = true) }

    if (!hasReleaseKey && (keyPropertiesFile.exists() || buildingBundle)) {
        val missing = listOf(
            "storeFile" to storeFilePath,
            "storePassword" to storePasswordValue,
            "keyAlias" to keyAliasValue,
        ).filter { it.second == null }.joinToString { it.first }
        throw GradleException(
            "Release signing is not configured (missing: $missing).\n" +
                "Copy android/key.properties-sample to android/key.properties and fill in your keystore details."
        )
    }

    val releaseKeystore: File? = storeFilePath?.let { path ->
        listOf(File(path), file(path), rootProject.file(path)).firstOrNull { it.isFile }
            ?: throw GradleException(
                "Keystore not found: $path\nCheck storeFile in android/key.properties " +
                    "(absolute path, or relative to android/app/)."
            )
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKey) {
                storeFile = releaseKeystore
                storePassword = storePasswordValue
                keyAlias = keyAliasValue
                keyPassword = keyPasswordValue
            }
        }
    }

    if (!hasReleaseKey) {
        logger.warn(
            "WARNING: android/key.properties not found — release APKs are signed with the DEBUG key " +
                "(fine for local testing, rejected by Google Play)."
        )
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasReleaseKey) "release" else "debug")
            isMinifyEnabled = true
            // Resource shrinking is off: Google Play services (AdMob, billing) looks up some of
            // its resources by name, and shrinking removed them. Code shrinking stays on.
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
