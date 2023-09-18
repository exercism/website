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

  useLayoutEffect(() => {
    if (!parentRef.current) {
      return
    }
    highlightAllAlways(parentRef.current as unknown as ParentNode)
  }, [html])

  return parentRef
}
