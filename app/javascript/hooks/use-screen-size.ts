import { useState, useEffect } from 'react'
import { debounce } from '@/utils/debounce'

const lgBreakpoint = 1024

export type UseWindowSizeResult = {
  isBelowLgWidth: boolean
  windowSize: Record<'width' | 'height', number>
}

export function useWindowSize(): UseWindowSizeResult {
  const [windowSize, setWindowSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  })

  useEffect(() => {
    const handleResize = debounce(() => {
      setWindowSize({
        width: window.innerWidth,
        height: window.innerHeight,
      })
    }, 300)

    window.addEventListener('resize', handleResize)

    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return { windowSize, isBelowLgWidth: windowSize.width <= lgBreakpoint }
}
