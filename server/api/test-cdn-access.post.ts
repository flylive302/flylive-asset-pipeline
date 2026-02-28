// server/api/test-cdn-access.post.ts
// Test if a CDN URL is publicly accessible (for debugging)
import { defineEventHandler, readBody } from 'h3'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { url } = body as { url: string }

  if (!url) {
    return { success: false, error: 'URL is required' }
  }

  try {
    console.log('Testing CDN access:', url)
    
    const response = await fetch(url, {
      method: 'HEAD', // Just check headers, don't download
    })

    const headers: Record<string, string> = {}
    response.headers.forEach((value, key) => {
      headers[key] = value
    })

    return {
      success: response.ok,
      status: response.status,
      statusText: response.statusText,
      headers,
      message: response.ok 
        ? '✅ URL is publicly accessible' 
        : `❌ URL returned ${response.status} ${response.statusText}`,
    }
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err)
    return {
      success: false,
      error: message,
      message: `❌ Failed to access URL: ${message}`,
    }
  }
})
