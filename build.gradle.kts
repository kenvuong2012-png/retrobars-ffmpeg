// FFmpeg decoders for media3 (software fallback for audio and video), plus an FFmpeg-based
// converter used when casting videos the TV can't play.
//
// Based on media3's decoder_ffmpeg extension (Apache 2.0). FFmpeg itself (LGPL 2.1 or later) is
// built with build_ffmpeg.sh (no GPL or non-free parts) into src/main/cpp/ffmpeg.
plugins {
    id("com.android.library")
}

android {
    namespace = "com.retrowave.ffmpeg"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("proguard-rules.pro")
        ndk {
            // FFmpeg is only built for ARM phones; other devices simply don't get the software decoders.
            abiFilters += listOf("arm64-v8a", "armeabi-v7a")
        }
        externalNativeBuild {
            cmake {
                arguments += listOf("-DANDROID_STL=c++_static")
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.31.6"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    val media3 = "1.9.4"
    api("androidx.media3:media3-decoder:$media3")
    implementation("androidx.media3:media3-exoplayer:$media3")
    implementation("androidx.annotation:annotation:1.9.1")
    compileOnly("org.checkerframework:checker-qual:3.49.3")
}
