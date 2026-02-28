# HEVC Encoding Troubleshooting Guide

## Current Issue

GitHub Actions workflow fails with "Invalid data found when processing input" error.

## Root Cause

The error indicates the WebM file download failed or is corrupted. Common causes:

1. **CDN URL not publicly accessible** - GitHub Actions runners need public access
2. **Authentication required** - CDN might require auth headers
3. **CORS restrictions** - CDN blocking external requests
4. **Incorrect URL format** - URL might be malformed

## Solution Steps

### 1. Verify WebM URL is Publicly Accessible

Test the WebM URL manually:
```bash
curl -I "YOUR_WEBM_URL_HERE"
```

Should return `200 OK` and `Content-Type: video/webm`

### 2. Check CDN Configuration

**For Cloudflare R2:**
- Ensure bucket has public read access OR
- Use R2 custom domain with public access
- Verify CORS settings allow external requests

**For ImageKit:**
- Ensure files are publicly accessible
- Check URL format is correct

### 3. Test Locally (macOS only)

If you have a Mac, test the encoding locally:

```bash
# Download your WebM
curl -o test.webm "YOUR_WEBM_URL"

# Verify it has alpha
ffmpeg -c:v libvpx-vp9 -i test.webm 2>&1 | grep yuva420p

# Encode to HEVC
ffmpeg -y -c:v libvpx-vp9 -i test.webm \
  -c:v hevc_videotoolbox \
  -allow_sw 1 \
  -alpha_quality 0.75 \
  -tag:v hvc1 \
  -movflags +faststart \
  test.mov

# Verify output has alpha
ffprobe test.mov | grep -i alpha
ffmpeg -i test.mov -frames:v 1 test.png
file test.png  # Should show RGBA
```

### 4. Updated Workflow with Better Diagnostics

The workflow has been updated with:
- Verbose curl output to see download issues
- File size validation
- Better error messages
- ffprobe debugging

### 5. Alternative: Direct Upload

If CDN URLs don't work, you can:

1. Upload WebM to GitHub repository
2. Modify workflow to use repository file instead of CDN URL
3. Or use GitHub Releases to host the WebM files

## Confirming HEVC with Alpha Works

Yes, HEVC with alpha transparency IS possible and works:

- ✅ Requires macOS (VideoToolbox encoder)
- ✅ Supported in Safari/iOS
- ✅ Works with WebM VP9 alpha as input
- ✅ Confirmed by multiple sources and Apple documentation

**Key Requirements:**
1. Use `-c:v libvpx-vp9` decoder for WebM input
2. Use `-c:v hevc_videotoolbox` encoder
3. Set `-alpha_quality > 0` (e.g., 0.75)
4. Use `-tag:v hvc1` for compatibility
5. Let encoder auto-select pixel format (don't specify `-pix_fmt`)

## Next Steps

1. **Check the GitHub Actions logs** - Go to your repository → Actions tab → Find the failed run → Check detailed logs
2. **Verify WebM URL accessibility** - Try downloading it with curl
3. **Re-run the workflow** - The updated workflow will show more diagnostic info
4. **Check CDN settings** - Ensure public read access

## Quick Fix Checklist

- [ ] WebM URL is publicly accessible (test with curl)
- [ ] CDN allows external requests (no auth required)
- [ ] GitHub secrets are configured (CLOUDFLARE_API_TOKEN, etc.)
- [ ] Workflow is using `macos-latest` runner
- [ ] WebM file actually has alpha channel (verify with `./scripts/verify-alpha.sh`)

## Example Working Command

```bash
ffmpeg -y -hide_banner \
  -c:v libvpx-vp9 -i input.webm \
  -c:v hevc_videotoolbox \
  -allow_sw 1 \
  -alpha_quality 0.75 \
  -tag:v hvc1 \
  -movflags +faststart \
  output.mov
```

This command is proven to work on macOS with VideoToolbox.
