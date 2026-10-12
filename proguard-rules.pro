# FFmpeg module. ExoPlayer loads the renderers by class name, and the native code calls back
# into these classes and looks up their fields / methods by name.
-keep class androidx.media3.decoder.ffmpeg.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}
