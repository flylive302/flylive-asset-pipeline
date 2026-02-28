# Tech Stack

## Framework & Runtime

- **Nuxt 3** (Vue 3) - Full-stack framework with SSR/SPA support
- **Node.js 18+** - Runtime environment
- **TypeScript** - Type-safe development

## Frontend

- **Vue 3** - Component framework
- **Pinia** - State management with persistence plugin
- **Vue Router** - Client-side routing
- Custom CSS (no UI framework) - Located in `assets/css/main.css`

## Backend (Nitro Server)

- **h3** - HTTP server framework (built into Nuxt)
- **better-sqlite3** - SQLite database for credentials, history, preferences
- **protobufjs** - SVGA format parsing
- **svga** library - SVGA animation support

## Video Processing

- **ffmpeg** - Video encoding (libvpx-vp9 for WebM)
- **ffprobe** - Video metadata extraction
- **hevc_videotoolbox** - HEVC encoding (macOS only)

## CDN & Deployment

- **Cloudflare R2** - Object storage via wrangler CLI
- **ImageKit** - Alternative CDN provider
- **GitHub Actions** - CI/CD for HEVC encoding on macOS runners

## Database Schema

SQLite tables:
- `credentials` - CDN provider credentials (R2, ImageKit, GitHub)
- `history` - Asset processing history
- `preferences` - User preferences

## Common Commands

```bash
# Development
npm run dev              # Start dev server (http://localhost:3000)

# Build
npm run build            # Production build
npm run generate         # Static site generation
npm run preview          # Preview production build

# Setup
npm install              # Install dependencies
npm run postinstall      # Nuxt preparation (auto-runs after install)

# Video Encoding (CLI)
./scripts/encode-webm.sh -i raw/file.mp4 -o output/webm/name/playable.webm --alpha-side right
./scripts/encode-hevc.sh -i raw/file.mp4 -o output/hevc/name/playable.mov --alpha-side right
./scripts/encode-all.sh -i raw/file.mp4 --alpha-side right --name asset_name
./scripts/batch-encode.sh --alpha-side right
./scripts/batch-encode.sh --csv batch.csv

# CDN Upload
./scripts/upload-r2.sh --name asset_name --type vip
./scripts/upload-r2.sh --all --gift-type normal
./scripts/upload-r2.sh --name asset_name --type vip --dry-run

# Wrangler (R2)
wrangler r2 object list flylive-assets
wrangler r2 object put flylive-assets/path/to/file.webm --file=local.webm
```

## External Dependencies

- **ffmpeg** + **ffprobe** must be installed on system
- **wrangler** CLI for R2 operations: `npm install -g wrangler`
- **uv** (optional) for Python-based tools

## Configuration Files

- `nuxt.config.ts` - Nuxt configuration
- `wrangler.toml` - Cloudflare R2 configuration
- `.env` - Environment variables (CDN credentials)
- `assets.json` - Asset manifest (generated)
- `alphaconvert.db` - SQLite database
