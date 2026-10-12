#!/bin/bash
# Builds FFmpeg (LGPL only: no --enable-gpl, no --enable-nonfree) as static libraries for the
# RetroBars FFmpeg module. Runs in Git Bash on Windows with the Android NDK's clang.
#
#   build_ffmpeg_retro.sh <ffmpeg source dir> <NDK dir> <output android-libs dir> [abi ...]
set -eu

SRC="$1"
NDK="$2"
OUT="$3"
shift 3
ABIS=("$@")
[ $# -eq 0 ] && ABIS=(arm64-v8a armeabi-v7a)
API=26
TC="$NDK/toolchains/llvm/prebuilt/windows-x86_64/bin"
JOBS="$(nproc 2>/dev/null || echo 8)"

# Software decoders used when the phone's hardware can't decode a stream.
VIDEO_DECODERS="h264 hevc mpeg1video mpeg2video mpeg4 h263 h263i flv msmpeg4v1 msmpeg4v2 msmpeg4v3 wmv1 wmv2 wmv3 vc1 vp8 vp9 mjpeg"
AUDIO_DECODERS="aac aac_latm ac3 eac3 dca truehd mlp mp1 mp2 mp3 mp3float mp2float vorbis opus flac alac amrnb amrwb
  wmav1 wmav2 wmapro wmalossless adpcm_ima_wav adpcm_ms
  pcm_s16le pcm_s16be pcm_s24le pcm_s32le pcm_u8 pcm_f32le pcm_mulaw pcm_alaw pcm_dvd pcm_bluray"
# For the TV converter: read these containers, write MP4.
DEMUXERS="mov matroska mpegts mpegps mpegvideo avi flv asf ogg h264 hevc aac ac3 eac3 dts mp3 wav"
PARSERS="h264 hevc mpeg4video mpegvideo vc1 aac aac_latm ac3 dca mlp mpegaudio vorbis opus flac vp8 vp9 h263 mjpeg"
BSFS="aac_adtstoasc extract_extradata h264_metadata hevc_mp4toannexb h264_mp4toannexb vp9_superframe"

OPTS=(
  --target-os=android --enable-cross-compile
  --enable-static --disable-shared --enable-pic
  --disable-doc --disable-programs --disable-everything
  --disable-avdevice --disable-postproc --disable-avfilter --disable-network
  --disable-symver --disable-debug --disable-v4l2-m2m --disable-vulkan
  --disable-autodetect --enable-jni --enable-mediacodec
  --enable-avcodec --enable-avformat --enable-avutil --enable-swresample --enable-swscale
  --enable-protocol=file
  --enable-muxer=mp4 --enable-muxer=mov
  --enable-encoder=aac --enable-encoder=h264_mediacodec
  --pkg-config=false
  --nm="$TC/llvm-nm.exe" --ar="$TC/llvm-ar.exe" --ranlib="$TC/llvm-ranlib.exe" --strip="$TC/llvm-strip.exe"
  --cc="$TC/clang.exe" --cxx="$TC/clang++.exe" --ld="$TC/clang.exe"
  --host-cc="$TC/clang.exe" --host-ld="$TC/clang.exe"
)
for d in $VIDEO_DECODERS $AUDIO_DECODERS; do OPTS+=("--enable-decoder=$d"); done
for d in $DEMUXERS; do OPTS+=("--enable-demuxer=$d"); done
for p in $PARSERS; do OPTS+=("--enable-parser=$p"); done
for b in $BSFS; do OPTS+=("--enable-bsf=$b"); done

cd "$SRC"
for ABI in "${ABIS[@]}"; do
  case "$ABI" in
    arm64-v8a) ARCH=aarch64; CPU=armv8-a; TRIPLE=aarch64-linux-android$API; EXTRA="" ;;
    armeabi-v7a) ARCH=arm; CPU=armv7-a; TRIPLE=armv7a-linux-androideabi$API; EXTRA="-march=armv7-a -mfloat-abi=softfp -mfpu=neon" ;;
    *) echo "Unsupported ABI $ABI"; exit 1 ;;
  esac
  echo "=== Building FFmpeg for $ABI ==="
  make distclean >/dev/null 2>&1 || true
  ./configure "${OPTS[@]}" \
    --arch=$ARCH --cpu=$CPU \
    --prefix="$OUT/$ABI" --libdir="$OUT/$ABI" --incdir="$OUT/include" \
    --extra-cflags="--target=$TRIPLE -O2 -fPIC $EXTRA -DANDROID" \
    --extra-ldflags="--target=$TRIPLE -Wl,-z,max-page-size=16384" \
    --host-cflags="--target=$TRIPLE" --host-ldflags="--target=$TRIPLE" \
    --extra-libs="-lmediandk -landroid"
  make -j"$JOBS"
  make install-libs install-headers
done
echo "Done: $OUT"
