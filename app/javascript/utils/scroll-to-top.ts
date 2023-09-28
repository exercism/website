export function scrollToTop(scrollToId?: string): void {
  if (!scrollToId) window.scrollTo(0, 0)
  else document.getElementById(`${scrollToId}`)?.scrollIntoView(true)
}
