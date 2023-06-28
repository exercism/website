export const debounce = (
  func: (...args: unknown[]) => void,
  delay: number
): ((...args: unknown[]) => void) => {
  let inDebounce: number | null
  return (...args: unknown[]) => {
    window.clearTimeout(inDebounce as number)
    inDebounce = window.setTimeout(() => func(...args), delay)
  }
}
