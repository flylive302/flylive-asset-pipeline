#!/usr/bin/env bash
set -euo pipefail

# verify-alpha.sh — Verify alpha channel in WebM or HEVC files
# Part of: FlyLive Asset Pipeline

progname=$(basename "$0")

usage() {
  cat <<EOF
Usage: $progname FILE

Verify if a video file contains an alpha channel (transparency).

Supports: WebM (.webm), HEVC (.mov), MP4

Examples:
  $progname output/webm/gift1/playable.webm
  $progname output/hevc/gift1/playable.mov
EOF
  exit "${1:-1}"
}

if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage 0
fi

FILE="$1"

if [[ ! -f "$FILE" ]]; then
  echo "Error: File not found: $FILE" >&2
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Alpha Channel Verification"
echo "  File: $FILE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Detect file type
EXT="${FILE##*.}"
CODEC=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$FILE")

echo "Codec: $CODEC"
echo ""

# Check metadata for alpha_mode flag
ALPHA_MODE=$(ffprobe -v error -show_entries format_tags=alpha_mode -of default=noprint_wrappers=1:nokey=1 "$FILE" 2>/dev/null || echo "")
if [[ -n "$ALPHA_MODE" ]]; then
  echo "✓ Metadata alpha_mode: $ALPHA_MODE"
fi

# For VP9, use libvpx-vp9 decoder to properly detect alpha
if [[ "$CODEC" == "vp9" ]]; then
  echo ""
  echo "Checking with libvpx-vp9 decoder (required for VP9 alpha)..."
  PIX_FMT=$(ffmpeg -c:v libvpx-vp9 -i "$FILE" 2>&1 | grep "Stream #0:0" | grep -oP 'yuva?\d+p' || echo "unknown")
  echo "Pixel format: $PIX_FMT"
  
  if [[ "$PIX_FMT" == *"yuva"* ]]; then
    echo ""
    echo "✅ ALPHA CHANNEL DETECTED (yuva format)"
  else
    echo ""
    echo "❌ NO ALPHA CHANNEL (yuv format without 'a')"
  fi
else
  # For other codecs, check pixel format directly
  PIX_FMT=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=noprint_wrappers=1:nokey=1 "$FILE")
  echo "Pixel format: $PIX_FMT"
  
  if [[ "$PIX_FMT" == *"a"* || "$PIX_FMT" == "bgra" || "$PIX_FMT" == "rgba" ]]; then
    echo ""
    echo "✅ ALPHA CHANNEL DETECTED"
  else
    echo ""
    echo "❌ NO ALPHA CHANNEL"
  fi
fi

# Extract a test frame
echo ""
echo "Extracting test frame..."
TMP_PNG="/tmp/alpha_test_$$.png"

# For VP9, use libvpx-vp9 decoder
if [[ "$CODEC" == "vp9" ]]; then
  ffmpeg -c:v libvpx-vp9 -i "$FILE" -frames:v 1 "$TMP_PNG" -y 2>/dev/null
else
  ffmpeg -i "$FILE" -frames:v 1 "$TMP_PNG" -y 2>/dev/null
fi

FILE_INFO=$(file "$TMP_PNG")
echo "Frame info: $FILE_INFO"

if echo "$FILE_INFO" | grep -q "RGBA"; then
  echo ""
  echo "✅ VERIFIED: Frame extracted with RGBA (transparency preserved)"
elif echo "$FILE_INFO" | grep -q "RGB"; then
  echo ""
  echo "❌ FAILED: Frame extracted as RGB only (no transparency)"
else
  echo ""
  echo "⚠️  UNKNOWN: Could not determine frame format"
fi

rm -f "$TMP_PNG"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
exit 0
