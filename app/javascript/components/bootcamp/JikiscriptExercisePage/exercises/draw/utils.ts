/**
 * Relative constant number the absolute number maps to
 */
export const RELATIVE_SIZE = 100
/**
 *
 * Convert relative x or y value to absolute value
 */
export function rToA(n: number) {
  return (n / RELATIVE_SIZE) * 100
}
/**
 *
 * Convert absolute x or y value to absolute value
 */
export function aToR(n: number, canvasSize: number) {
  return (n / canvasSize) * RELATIVE_SIZE
}
