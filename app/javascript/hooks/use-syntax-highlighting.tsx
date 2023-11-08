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
  const prevHtml = useRef<string | undefined>(undefined)

  useLayoutEffect(() => {
    if (!parentRef.current || prevHtml.current === html) {
      return
    }

    highlightAllAlways(parentRef.current as unknown as ParentNode)

    prevHtml.current = html
  }, [html])

  return parentRef
}
