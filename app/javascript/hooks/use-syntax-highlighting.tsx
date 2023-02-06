import { useRef, useEffect, RefObject } from 'react'
import { highlightAll } from '@/utils'

export function useHighlighting<T>(html?: string): RefObject<T> {
  const parentRef = useRef<T | null>(null)

  useEffect(() => {
    if (!parentRef.current) {
      return
    }

    highlightAll(parentRef.current as unknown as ParentNode)
  }, [html])

  return parentRef
}
