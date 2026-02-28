# Product Overview

FlyLive Asset Pipeline is a video conversion tool that transforms raw alpha-packed MP4 files into browser-ready video assets with transparency support.

## Core Purpose

Convert designer-provided side-by-side MP4 videos (color + alpha matte) into:
- WebM VP9 with alpha channel (Chrome/Android)
- HEVC with alpha channel (Safari/iOS)
- PNG thumbnails

## Key Features

- GUI-based upload and processing interface
- CLI scripts for batch automation
- CDN upload integration (Cloudflare R2, ImageKit)
- Asset history tracking with SQLite
- GitHub Actions workflow for HEVC encoding on macOS

## Target Users

- Designers uploading gift animations
- Developers integrating transparent video assets
- DevOps automating asset pipelines

## Asset Types

- VIP gifts: Premium animated gifts
- Normal gifts: Standard animated gifts
- SVGA animations: Legacy format support
