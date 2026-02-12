/**
 * Safely access window.localStorage.
 *
 * In some browsers (Safari private browsing, restricted iframes, strict cookie
 * settings) even reading window.localStorage throws a SecurityError.  This
 * helper returns null when access is denied so callers can degrade gracefully.
 */
export function safeLocalStorage(): Storage | null {
  try {
    return window.localStorage
  } catch {
    return null
  }
}
