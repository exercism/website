/* eslint-disable @typescript-eslint/no-explicit-any */
// any is descriptive here
// using unknown would make thigs very hard to read
export function debounce<F extends (...args: any[]) => any>(
  func: F,
  delay: number
): (...args: Parameters<F>) => void {
  let inDebounce: ReturnType<typeof setTimeout> | null = null
  return (...args: Parameters<F>): void => {
    clearTimeout(inDebounce as ReturnType<typeof setTimeout>)
    inDebounce = setTimeout(() => func(...args), delay)
  }
}
