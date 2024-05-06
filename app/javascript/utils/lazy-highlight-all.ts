import { isLookbehindSupported } from './regex-check'

export function lazyHighlightAll(): void {
  if (!isLookbehindSupported()) return
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

  function checkAndInitHighlighting() {
    if (!shouldApplySyntaxHighlighting(document)) return

    applySyntaxHighlighting()
  }

  function handleDOMChanges(mutationsList: MutationRecord[]): void {
    for (const mutation of mutationsList) {
      if (mutation.type !== 'childList') continue

      for (const node of mutation.addedNodes) {
        if (node.nodeType !== Node.ELEMENT_NODE) continue

        if (shouldApplySyntaxHighlighting(node as Element)) {
          applySyntaxHighlighting()
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
function shouldApplySyntaxHighlighting(rootNode: Document | Element): boolean {
  return rootNode.querySelector('code:not(.hljs)') !== null
}
