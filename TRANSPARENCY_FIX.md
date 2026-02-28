# Transparency Fix for WebM → HEVC Pipeline

## Problem Summary

HEVC `.mov` files were not preserving transparency from WebM sources.

## Root Cause

The GitHub Actions workflow was not using the correct VP9 decoder. The default VP9 decoder drops the alpha channel even though the WebM file contains it (indicated by `alpha_mode: 1` in metadata).

## Solution

### Key Findings from FFmpeg Documentation

1. **VP9 Alpha Detection Issue**: `ffprobe` reports VP9 alpha files as `yuv420p` instead of `yuva420p`, but the alpha IS present. You must use `-c:v libvpx-vp9` decoder explicitly to access it.

2. **hevc_videotoolbox Requirements**:
   - Only available on macOS (Apple VideoToolbox)
   - Accepts `bgra` pixel format for alpha (NOT `yuva420p`)
   - Auto-selects correct format - do NOT specify `-pix_fmt`
   - Requires `-alpha_quality > 0` to enable "HEVC Video with Alpha" profile
   - Use `-tag:v hvc1` for broad compatibility

### Fixed GitHub Actions Workflow

```bash
ffmpeg -y -hide_banner -loglevel info \
  -c:v libvpx-vp9 -i tmp/input.webm \
  -c:v hevc_videotoolbox \
  -allow_sw 1 \
  -alpha_quality 0.75 \
  -tag:v hvc1 \
  -movflags +faststart \
  -c:a aac -b:a 128k \
  output.mov
```

### What Changed

**Before**:
- Used default VP9 decoder (drops alpha)
- Specified `-filter_complex` and `-pix_fmt` (causes format conflicts)

**After**:
- Uses `-c:v libvpx-vp9` decoder (preserves alpha)
- Removed `-pix_fmt` specification (let hevc_videotoolbox auto-select bgra)
- Simplified command (no filter_complex needed)

## Verification

### Check if WebM has alpha:
```bash
# Wrong way (shows yuv420p even with alpha):
ffprobe input.webm

# Correct way (shows yuva420p if alpha present):
ffmpeg -c:v libvpx-vp9 -i input.webm 2>&1 | grep "Stream #0:0"
```

### Check if HEVC has alpha:
```bash
ffprobe output.mov
# Look for pixel format with alpha (e.g., yuva420p, bgra)
```

### Extract transparent frame:
```bash
ffmpeg -i output.mov -frames:v 1 test.png
file test.png  # Should show "RGBA" not "RGB"
```

## Current Status

- ✅ WebM encoding already works correctly (alpha preserved)
- ✅ GitHub Actions workflow updated with correct decoder
- ⚠️ Existing HEVC files need re-encoding with new workflow

## Next Steps

1. Push the updated `.github/workflows/encode-hevc.yml` to master
2. Re-trigger HEVC encoding for existing assets via the web UI
3. Verify transparency in output `.mov` files

## References

- [FFmpeg Ticket #8468](https://trac.ffmpeg.org/ticket/8468) - VP9 yuva420p encoding
- [FFmpeg Ticket #11165](https://trac.ffmpeg.org/ticket/11165) - VP9 decoder alpha handling
- [Stack Overflow: Convert WEBM to HEVC with alpha](https://stackoverflow.com/questions/61661140/convert-webm-to-hevc-with-alpha)
