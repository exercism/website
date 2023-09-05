export function lazyHighlightAll(): void {
  let highlighted = false

  function applySyntaxHighlighting() {
    import('@/utils/highlight')
      .then((m) => {
        m.highlightAll()
        observer.disconnect()
      })
      .catch((e) => {
        observer.disconnect()
        throw new Error(e)
      })
  }

  function initAndApplyHighlighting() {
    // to avoid race conditions, set this optimistically to true before the async loading
    highlighted = true
    applySyntaxHighlighting()
  }

  function checkAndInitHighlighting() {
    if (!shouldApplySyntaxHighlighting(document, highlighted)) return
    initAndApplyHighlighting()
  }

  function handleDOMChanges(mutationsList: MutationRecord[]): void {
    for (const mutation of mutationsList) {
      if (mutation.type !== 'childList') continue
      for (const node of mutation.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE) continue
        if (shouldApplySyntaxHighlighting(node as Element, highlighted)) {
          initAndApplyHighlighting()
          return
        }
      }
    }
  }

  checkAndInitHighlighting()

  const observer = new MutationObserver(handleDOMChanges)
  observer.observe(document.body, { childList: true, subtree: true })
}

// only load highlightjs when a code block exists in the DOM and it hasn't been highlighted yet
function shouldApplySyntaxHighlighting(
  rootNode: Document | Element,
  highlighted: boolean
): boolean {
  return rootNode.querySelector('code') !== null && !highlighted
}
