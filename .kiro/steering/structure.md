# Project Structure

## Root Layout

```
├── .kiro/              # Kiro IDE configuration
├── .nuxt/              # Nuxt build artifacts (generated)
├── .output/            # Production build output (generated)
├── app.vue             # Root Vue component with layout
├── nuxt.config.ts      # Nuxt configuration
├── package.json        # Dependencies and scripts
├── tsconfig.json       # TypeScript configuration
├── alphaconvert.db     # SQLite database
├── assets.json         # Asset manifest (generated)
└── wrangler.toml       # Cloudflare R2 configuration
```

## Source Directories

### `/pages` - Route Pages
Auto-routed Vue components:
- `index.vue` - Dashboard/home
- `convert.vue` - Upload & process interface
- `history.vue` - Asset processing history
- `settings.vue` - CDN credentials configuration
- `cdn-upload.vue` - CDN upload interface

### `/components` - Vue Components
- `SvgaPlayer.client.vue` - SVGA animation player (client-only)
- `layout/` - Layout components (sidebar, navigation)

### `/composables` - Vue Composables
Reusable composition functions:
- `useFormatters.ts` - Formatting utilities

### `/stores` - Pinia State
- `app.ts` - Application state management

### `/server` - Backend API
Nitro server with auto-imported utilities:

**API Routes** (`/server/api/`):
- `process.post.ts` - Trigger video encoding
- `process-svga.post.ts` - SVGA conversion
- `upload.post.ts` - File upload handler
- `upload-cdn.post.ts` - CDN upload orchestration
- `upload-thumbnail.post.ts` - Thumbnail upload
- `trigger-hevc.post.ts` - HEVC encoding trigger
- `settings.ts` - GET/POST credentials
- `history.ts` - Asset history CRUD
- `hevc-download-url.get.ts` - Generate download URLs
- `list-cdn-r2.get.ts` - List R2 bucket contents
- `list-cdn-imagekit.get.ts` - List ImageKit assets
- `assets.get.ts` - Asset manifest endpoint
- `assets/[name].put.ts` - Update asset
- `assets/[name].delete.ts` - Delete asset
- `preview/[...path].get.ts` - Asset preview proxy

**Utilities** (`/server/utils/`):
- `db.ts` - SQLite database helpers (credentials, history, preferences)
- `types.ts` - Shared TypeScript types
- `env.ts` - Environment variable access
- `manifest.ts` - Asset manifest management
- `cdn-types.ts` - CDN provider types

### `/scripts` - Shell Scripts
Bash scripts for video encoding and CDN operations:
- `encode-webm.sh` - WebM VP9 + alpha encoding
- `encode-hevc.sh` - HEVC + alpha encoding (macOS only)
- `encode-all.sh` - Encode both formats + thumbnail
- `batch-encode.sh` - Batch processing with CSV support
- `upload-r2.sh` - Upload assets to Cloudflare R2

### `/assets` - Static Assets
- `css/main.css` - Global styles

### `/public` - Public Static Files
Served at root:
- `favicon.ico`
- `robots.txt`

## Working Directories

### `/raw` - Input Videos
Raw side-by-side MP4 files from designers (not committed to git)

### `/output` - Encoded Assets
Generated video outputs (not committed to git):
```
output/
├── webm/{name}/
│   ├── playable.webm
│   └── thumbnail.png
└── hevc/{name}/
    └── playable.mov
```

## Configuration Files

- `.env` - Environment variables (CDN credentials, secrets)
- `.env.example` - Environment template
- `.gitignore` - Git ignore rules
- `wrangler.toml` - R2 bucket configuration

## Conventions

### API Routes
- Use h3 event handlers: `defineEventHandler()`
- POST endpoints for mutations, GET for queries
- Return `{ success: boolean, error?: string }` for operations
- Use `readBody()` for request parsing

### Database Access
- Import helpers from `server/utils/db`
- Use prepared statements via better-sqlite3
- JSON columns for complex data (formats, cdn_urls)
- Timestamps in ISO 8601 format

### File Naming
- Vue components: PascalCase (e.g., `SvgaPlayer.vue`)
- Composables: camelCase with `use` prefix (e.g., `useFormatters.ts`)
- API routes: kebab-case with HTTP method suffix (e.g., `process.post.ts`)
- Utilities: kebab-case (e.g., `cdn-types.ts`)

### Asset Naming
- Output names: snake_case or kebab-case
- CDN paths: `room/gifts/{vip-gifts|normal}/{name}/playable.{webm|mov}`
- Thumbnails: `thumbnail.png` in same directory as video

### Shell Scripts
- All scripts support `--help` flag
- Use long-form flags for clarity (e.g., `--alpha-side` not `-a`)
- Exit with non-zero on errors
- Log progress to stdout, errors to stderr
