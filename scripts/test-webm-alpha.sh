#!/usr/bin/env bash
set -euo pipefail

# test-webm-alpha.sh — Test if a WebM file has alpha channel
# Usage: ./scripts/test-webm-alpha.sh path/to/file.webm

if [ $# -eq 0 ]; then
  echo "Usage: $0 <webm-file>"
  echo ""
  echo "Tests if a WebM file contains an alpha channel."
  exit 1
fi

WEBM_FILE="$1"

if [ ! -f "$WEBM_FILE" ]; then
  echo "❌ File not found: $WEBM_FILE"
  exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Testing WebM Alpha Channel"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "File: $WEBM_FILE"
echo ""

# Test 1: Default decoder (often shows yuv420p even if alpha exists)
echo "📋 Test 1: Default decoder pixel format"
PIX_FMT_DEFAULT=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=noprint_wrappers=1:nokey=1 "$WEBM_FILE")
echo "   Result: $PIX_FMT_DEFAULT"

# Test 2: VP9 decoder (should show yuva420p if alpha exists)
echo ""
echo "📋 Test 2: VP9 decoder pixel format (correct detection)"
PIX_FMT_VP9=$(ffmpeg -c:v libvpx-vp9 -i "$WEBM_FILE" -f null - 2>&1 | grep -oP 'yuva?\d+p' | head -1 || echo "unknown")
echo "   Result: $PIX_FMT_VP9"

# Test 3: Extract a frame and check if it has alpha
echo ""
echo "📋 Test 3: Extract frame and check alpha"
TMP_PNG=$(mktemp --suffix=.png)
trap 'rm -f "$TMP_PNG"' EXIT

if ffmpeg -y -hide_banner -loglevel error -c:v libvpx-vp9 -i "$WEBM_FILE" -frames:v 1 "$TMP_PNG" 2>/dev/null; then
  PNG_COLOR=$(identify -format '%[channels]' "$TMP_PNG" 2>/dev/null || echo "unknown")
  echo "   PNG channels: $PNG_COLOR"
  
  if [[ "$PNG_COLOR" == *"a"* ]] || [[ "$PNG_COLOR" == *"A"* ]]; then
    echo "   ✅ Frame has alpha channel"
  else
    echo "   ❌ Frame does NOT have alpha channel"
  fi
else
  echo "   ⚠️  Could not extract frame"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ "$PIX_FMT_VP9" == "yuva420p" ]]; then
  echo "✅ WebM file HAS alpha channel (yuva420p)"
  echo ""
  echo "This file should work for HEVC conversion with transparency."
  exit 0
elif [[ "$PIX_FMT_VP9" == "yuv420p" ]]; then
  echo "❌ WebM file DOES NOT have alpha channel (yuv420p)"
  echo ""
  echo "This file will NOT produce transparent HEVC output."
  echo "Check your WebM encoding settings."
  exit 1
else
  echo "⚠️  Could not determine alpha channel status"
  echo "   VP9 decoder result: $PIX_FMT_VP9"
  exit 2
fi
