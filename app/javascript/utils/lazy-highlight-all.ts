export function lazyHighlightAll(): void {
  let highlighted = false

  function loadAndHighlight() {
    import('@/utils/highlight')
      .then((m) => {
        m.highlightAll()
        observer.disconnect()
      })
      .catch((e) => {
        highlighted = false
        // eslint-disable-next-line no-console
        console.error(e)
      })
  }

  function checkAndHighlight(): void {
    // only load highlightjs when a code block with lang-... or language-... classname exists in the DOM
    if (highlighted || !hasHighlightableCodeBlock(document)) return

    // to avoid race conditions, set this optimistically to true before the async loading
    highlighted = true
    loadAndHighlight()
  }

  function mutationCallback(mutationsList: MutationRecord[]): void {
    for (const mutation of mutationsList) {
      if (mutation.type !== 'childList') continue
      for (const node of mutation.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE) continue
        if (hasHighlightableCodeBlock(node as Element)) {
          checkAndHighlight()
          return
        }
      }
    }
  }

  checkAndHighlight()

  const observer = new MutationObserver(mutationCallback)
  observer.observe(document.body, { childList: true, subtree: true })

  // if no code block is found within 2 seconds after the turbo:load event, disconnect the observer.
  setTimeout(() => {
    observer.disconnect()
  }, 2000)
}

function hasHighlightableCodeBlock(rootNode: Document | Element): boolean {
  return (
    rootNode.querySelector('code[class^=lang-]') !== null ||
    rootNode.querySelector('code[class^=language-]') !== null
  )
}
