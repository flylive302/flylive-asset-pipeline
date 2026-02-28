# HEVC Transparency Fix - Final Solution

## Problem Summary

HEVC .mov files were not showing transparency in Safari/iOS - they displayed a black background instead.

## Root Cause

The issue was the **pixel format**. VideoToolbox was encoding HEVC with `ayuv` pixel format, but Safari/iOS requires `bgra` format to properly render transparency.

## Solution

Updated `.github/workflows/encode-hevc.yml` to explicitly convert to `bgra` format using the `scale_vt` filter:

```bash
ffmpeg -y -hide_banner -loglevel info \
  -c:v libvpx-vp9 -i tmp/input.webm \
  -vf "scale_vt=format=bgra" \
  -c:v hevc_videotoolbox \
  -allow_sw 1 \
  -alpha_quality 0.75 \
  -tag:v hvc1 \
  -movflags +faststart \
  "output/hevc/asset_name/playable.mov"
```

Key changes:
1. Added `-vf "scale_vt=format=bgra"` to force bgra pixel format
2. Removed audio encoding (not needed for gift animations)
3. Enhanced verification step to check pixel format

## Why bgra Format?

According to Apple's HEVC with Alpha documentation and real-world testing:
- `ayuv` format: Technically correct for alpha, but Safari/iOS doesn't render it
- `bgra` format: Required for Safari/iOS to properly display transparency
- The `scale_vt` filter performs GPU-accelerated conversion to bgra

## Testing WebM Files

Before converting to HEVC, verify your WebM files have alpha:

```bash
./scripts/test-webm-alpha.sh output/webm/asset_name/playable.webm
```

This will check if the WebM file contains a proper alpha channel (yuva420p).

## Upload Timeout Fix

Increased timeout for video processing from 5 minutes to 10 minutes in `server/api/process.post.ts` to handle large files.

## How to Test

1. Upload a side-by-side MP4 file
2. Convert to WebM (should produce yuva420p format)
3. Upload WebM to CDN
4. Trigger HEVC encoding via GitHub Actions
5. Download the .mov file
6. Test in Safari - transparency should work

## Verification Commands

Check WebM alpha (correct method):
```bash
ffmpeg -c:v libvpx-vp9 -i file.webm -f null - 2>&1 | grep yuva420p
```

Check HEVC pixel format:
```bash
ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=noprint_wrappers=1:nokey=1 file.mov
# Should output: bgra
```

Extract frame to verify transparency:
```bash
ffmpeg -i file.mov -frames:v 1 test.png
file test.png  # Should show "PNG image data, ... 8-bit/color RGBA"
```

## Browser Compatibility

- Chrome/Android: WebM VP9 with alpha (yuva420p)
- Safari/iOS: HEVC with alpha (bgra format required)

## References

- [Apple WWDC 2019: HEVC Video with Alpha](https://developer.apple.com/videos/play/wwdc2019/506/)
- [Centricular: VideoToolbox HEVC Alpha](https://centricular.com/devlog/2024-08/videotoolbox-hevc-alpha/)
- Safari requires bgra pixel format for HEVC alpha transparency
- FFmpeg VP9 decoder requires `-c:v libvpx-vp9` flag to detect alpha
