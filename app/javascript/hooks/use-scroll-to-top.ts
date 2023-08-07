import { useEffect } from 'react'

export function useScrollToTop(
  elementReference: HTMLElement,
  stateUpdate: unknown
): void {
  useEffect(() => {
    elementReference.scrollIntoView(true)
  }, [elementReference, stateUpdate])
}
