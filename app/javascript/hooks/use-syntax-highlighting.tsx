import { useRef, RefObject, useLayoutEffect } from 'react'
import { highlightAll } from '@/utils'

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
