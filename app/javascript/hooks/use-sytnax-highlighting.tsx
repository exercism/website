import { useRef, useEffect, RefObject } from 'react'
import { highlightAll } from '../utils/highlight'

export function useSyntaxHighlighting(html: string): RefObject<HTMLDivElement> {
  const contentRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!contentRef.current) {
      return
    }

    highlightAll(contentRef.current)
  }, [html])

  return contentRef
}
