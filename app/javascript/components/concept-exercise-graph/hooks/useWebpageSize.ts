import { useState, useEffect } from 'react'

type WebpageSize = {
  width: undefined | number
  height: undefined | number
}

export function useWebpageSize() {
  // Initialize state with undefined width/height so server and client renders match
  // Learn more here: https://joshwcomeau.com/react/the-perils-of-rehydration/

  const [webpageSize, setWebpageSize] = useState({
    width: undefined,
    height: undefined,
  } as WebpageSize)

  useEffect(() => {
    function handleResize() {
      setWebpageSize({
        width: document.documentElement.clientWidth,
        height: document.body.scrollHeight,
      })
    }

    window.addEventListener('resize', handleResize)
    handleResize()

    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return {
    width: webpageSize.width ?? 0,
    height: webpageSize.height ?? 0,
  }
}
