/**
 * Scrolls the page to a specific element identified by the `data-scroll-top-anchor` attribute.
 * If no anchor is provided, the function defaults to scrolling to the top of the page.
 *
 * @param {string} [anchorName] - The value for the `data-scroll-top-anchor` attribute.
 *                                Ensure the element has this attribute format: `data-scroll-top-anchor="${anchorName}"`.
 * @param {number} [yOffset=0] - The vertical offset from the element. A positive value scrolls above the element,
 *                               while a negative value scrolls below.
 *
 * @example
 * HTML element:
 * ```html
 * <div data-scroll-top-anchor="contributors-list"></div>
 * ```
 * JavaScript:
 * ```javascript
 * scrollToTop("contributors-list", 32);  // Scrolls to 32 pixels above the element.
 * ```
 */
export function scrollToTop(
  anchorName?: string,
  yOffset?: number,
  behavior?: ScrollBehavior
): void {
  if (!anchorName) {
    window.scrollTo(0, 0)
  } else {
    const element = document.querySelector(
      `[data-scroll-top-anchor="${anchorName}"]`
    )
    if (!element) return
    const rect = element.getBoundingClientRect()
    const currentScrollPosition =
      window.scrollY || document.documentElement.scrollTop
    window.scrollTo({
      top: currentScrollPosition + rect.top - (yOffset || 0),
      behavior: behavior || 'instant',
    })
  }
}
