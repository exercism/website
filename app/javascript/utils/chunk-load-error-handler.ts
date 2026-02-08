const RELOAD_KEY = 'exercism:chunk-reload-timestamp'
const RELOAD_COOLDOWN_MS = 10_000

/**
 * Detects dynamic import failures across all major browsers.
 *
 * Chrome/Edge: "Failed to fetch dynamically imported module: <url>"
 * Firefox: "error loading dynamically imported module: <url>"
 * Safari: "Importing a module script failed."
 */
export function isChunkLoadError(error: unknown): boolean {
  if (!(error instanceof Error)) return false
  const msg = error.message.toLowerCase()
  return (
    msg.includes('failed to fetch dynamically imported module') ||
    msg.includes('error loading dynamically imported module') ||
    msg.includes('importing a module script failed')
  )
}

/**
 * Reloads the page to pick up new assets after a deployment,
 * with sessionStorage-based cooldown to prevent infinite reload loops.
 */
export function safeReloadForChunkError(): void {
  try {
    const lastReload = sessionStorage.getItem(RELOAD_KEY)
    const now = Date.now()

    if (lastReload && now - parseInt(lastReload, 10) < RELOAD_COOLDOWN_MS) {
      return
    }

    sessionStorage.setItem(RELOAD_KEY, String(now))
  } catch {
    // sessionStorage may be unavailable (private browsing, storage full).
    // Reload anyway — worst case is one extra reload.
  }

  window.location.reload()
}
