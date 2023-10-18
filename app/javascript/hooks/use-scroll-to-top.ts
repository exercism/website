import { useEffect, useRef } from 'react'

/**
 *
 * @param stateUpdate The state the dependency array listens to
 * @returns a ref that will be scrolled to top of the screen on state update
 */
export function _useScrollToTop<T extends HTMLElement>(
  stateUpdate: unknown
): React.RefObject<T> | undefined {
  const scrollToTopRef = useRef<T>(null)
  const isInitialMount = useRef(true)

  useEffect(() => {
    if (isInitialMount.current) {
      isInitialMount.current = false
      return
    }
    if (
      scrollToTopRef.current &&
      typeof scrollToTopRef.current.scrollIntoView === 'function'
    ) {
      scrollToTopRef.current.scrollIntoView(true)
    }
  }, [stateUpdate])

  return scrollToTopRef
}

export function useScrollToTop(stateUpdate: unknown): void {
  useEffect(() => {
    window.scrollTo(0, 0)
  }, [stateUpdate])
}
