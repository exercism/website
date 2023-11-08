import { useRef, RefObject, useLayoutEffect } from 'react'
import { highlightAll, highlightAllAlways } from '@/utils/highlight'

export function useHighlighting<T extends HTMLElement>(
  html?: string
): RefObject<T> {
  const parentRef = useRef<T | null>(null)

  useLayoutEffect(() => {
    if (!parentRef.current) {
      return
    }
    highlightAll(parentRef.current as unknown as ParentNode)
  }, [html])

  return parentRef
}
export function useContinuousHighlighting<T extends HTMLElement>(
  html?: string
): RefObject<T> {
  const parentRef = useRef<T | null>(null)
  const hasRunHighlighting = useRef(false)
  const prevHtml = useRef<string | undefined>(undefined)

  useLayoutEffect(() => {
    if (hasRunHighlighting.current && prevHtml.current === html) {
      return
    }

    if (!parentRef.current || prevHtml.current === html) {
      return
    }

    highlightAllAlways(parentRef.current as unknown as ParentNode)

    hasRunHighlighting.current = true
    prevHtml.current = html

    // Reset the hasRunHighlighting flag on unmount to ensure it runs again after re-mounting
    return () => {
      hasRunHighlighting.current = false
    }
  }, [html])

  return parentRef
}
