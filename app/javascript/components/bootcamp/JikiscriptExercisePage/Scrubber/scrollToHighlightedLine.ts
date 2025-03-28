export function scrollToHighlightedLine() {
  const line = document.querySelector('.cm-highlightedLine') as HTMLElement
  const scroller = document.querySelector('.cm-scroller') as HTMLElement

  const scrollToLine = (line: HTMLElement, scroller: HTMLElement) => {
    const lineRect = line.getBoundingClientRect()
    const scrollerRect = scroller.getBoundingClientRect()
    const offsetY = lineRect.top - scrollerRect.top + scroller.scrollTop

    scroller.scrollTo({
      top: offsetY - scroller.clientHeight / 2,
      left: 0,
      behavior: 'instant',
    })
  }

  if (line && scroller) {
    scrollToLine(line, scroller)
  }
}
