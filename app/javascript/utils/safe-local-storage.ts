/**
 * Safely access window.localStorage.
 *
 * In some browsers (Safari private browsing, restricted iframes, strict cookie
 * settings) even reading window.localStorage throws a SecurityError.  Some
 * browsers allow reading the property but throw on actual storage operations.
 * This helper tests a real write/remove cycle and returns null when access is
 * denied so callers can degrade gracefully.
 */
export function safeLocalStorage(): Storage | null {
  try {
    const storage = window.localStorage
    const testKey = '__exercism_storage_test__'
    storage.setItem(testKey, 'test')
    storage.removeItem(testKey)
    return storage
  } catch {
    return null
  }
}
