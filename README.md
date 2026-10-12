# RetroBars FFmpeg module

Software decoders for ExoPlayer and the video converter used for casting, built on FFmpeg.

## What's in it

- `src/main/java/androidx/media3/decoder/ffmpeg/`: media3's FFmpeg extension (Apache 2.0, from
  androidx/media tag `1.9.4`, `libraries/decoder_ffmpeg`), changed for RetroBars:
  - `FfmpegLibrary`: codec names for MPEG-1/2, MPEG-4, H.263, MS-MPEG4, WMV 1/2/3, VC-1, VP8/9, MJPEG, WMA.
  - `FfmpegAudioDecoder`: passes block alignment / bitrate (needed by WMA).
  - `ExperimentalFfmpegVideoRenderer` + `FfmpegVideoDecoder`: a working software video renderer
    (media3 ships only a placeholder). It is a fallback: hardware decoders are always tried first.
  - `FfmpegConverter`: converts any readable video to MP4 (H.264/HEVC + AAC) for Chromecast.
- `src/main/cpp/`: JNI code (`ffmpeg_jni.cc` from media3, plus `ffmpeg_video_jni.cc` and
  `ffmpeg_convert.cc`), and the prebuilt FFmpeg static libraries in `ffmpeg/android-libs/<abi>`
  with headers in `ffmpeg/include`.

## Licence

FFmpeg 7.1.5 is used **unmodified** under the GNU LGPL 2.1 or later. It is configured with
`--disable-everything` and only the decoders / demuxers / parsers listed in `build_ffmpeg.sh`;
**no `--enable-gpl` and no `--enable-nonfree`** (configure reports "License: LGPL version 2.1 or later").

To meet the LGPL, whoever receives the app must be able to get the FFmpeg source, this module's
source and the build script, so they can rebuild and replace `libffmpegJNI.so`. The app's About ▸
Open-source licences page links to the FFmpeg source and offers the rest by e-mail for three years.
Publishing this `ffmpeg/` folder (without `android-libs`) somewhere public is the easiest way to honour that.

## Rebuilding FFmpeg (Windows, no WSL needed)

Needs Git for Windows (Git Bash), GNU make (the MSYS2 `make` package works in Git Bash), and the
Android NDK r29 (`29.0.14206865`).

```bash
curl -O https://ffmpeg.org/releases/ffmpeg-7.1.5.tar.xz && tar -xf ffmpeg-7.1.5.tar.xz
export TMPDIR=$PWD/tmp && mkdir -p $TMPDIR
bash build_ffmpeg.sh $PWD/ffmpeg-7.1.5 $LOCALAPPDATA/Android/Sdk/ndk/29.0.14206865 $PWD/android-libs arm64-v8a armeabi-v7a
```

Then copy `android-libs/<abi>/*.a` to `src/main/cpp/ffmpeg/android-libs/<abi>/` and
`android-libs/include` to `src/main/cpp/ffmpeg/include`. Only arm64-v8a and armeabi-v7a are built;
other devices run the app without the software decoders.
