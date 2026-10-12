# RetroBars Player – FFmpeg library source

This is the complete source for `libffmpegJNI.so` in the RetroBars Player Android app, provided under
the GNU LGPL 2.1 (FFmpeg) and Apache License 2.0 (media3 FFmpeg extension code).

- FFmpeg 7.1.5, unmodified, LGPL 2.1 or later: https://ffmpeg.org/releases/ffmpeg-7.1.5.tar.xz
  (headers are included in `src/main/cpp/ffmpeg/include`; licence text in `COPYING.LGPLv2.1`).
- Build configuration: `build_ffmpeg.sh` (no `--enable-gpl`, no `--enable-nonfree`).
- JNI and Java code in `src/main/`: based on androidx/media `libraries/decoder_ffmpeg` (tag 1.9.4,
  Apache 2.0, see `LICENSE-APACHE-2.0.txt`), changed for RetroBars as described in `README.md`.

To use your own FFmpeg build: build it with `build_ffmpeg.sh`, put the `.a` files in
`src/main/cpp/ffmpeg/android-libs/<abi>/`, build this module and replace `libffmpegJNI.so` in the app.
