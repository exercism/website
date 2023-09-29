export function scrollToTop(anchorName?: string, yOffset?: number): void {
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
      behavior: 'instant',
    })
  }
}
