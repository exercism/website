export function lazyHighlightAll(): void {
  let highlighted = false

  function checkAndHighlight(): void {
    if (highlighted) return

    // only load highlightjs when a code block with lang-... or language-... classname exists in the DOM
    if (
      document.querySelector('code[class^=lang-]') !== null ||
      document.querySelector('code[class^=language-]') !== null
    ) {
      // to avoid race conditions, set this optimistically to true before the async operations
      highlighted = true
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
  }

  function mutationCallback(mutationsList: MutationRecord[]): void {
    for (const mutation of mutationsList) {
      if (mutation.type === 'childList') {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === Node.ELEMENT_NODE) {
            if (
              (node as Element).querySelector('code[class^=lang-]') !== null ||
              (node as Element).querySelector('code[class^=language-]') !== null
            ) {
              checkAndHighlight()
              return
            }
          }
        }
      }
    }
  }

  checkAndHighlight()

  const observer = new MutationObserver(mutationCallback)
  observer.observe(document.body, { childList: true, subtree: true })
}
