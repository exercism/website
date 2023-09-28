export function scrollToTop(anchorName?: string): void {
  if (!anchorName) {
    window.scrollTo(0, 0)
  } else {
    const element = document.querySelector(
      `[data-scroll-top-anchor="${anchorName}"]`
    )
    if (element) {
      element.scrollIntoView(true)
    }
  }
}
