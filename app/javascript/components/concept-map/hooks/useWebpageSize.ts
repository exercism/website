import { useState, useEffect } from 'react'

type WebpageSize = {
  width: undefined | number
  height: undefined | number
}

export function useWebpageSize() {
  const [webpageSize, setWebpageSize] = useState({
    width: document.documentElement.clientWidth,
    height: document.body.scrollHeight,
  } as WebpageSize)

  useEffect(() => {
    function handleResize() {
      setWebpageSize({
        width: document.documentElement.clientWidth,
        height: document.body.scrollHeight,
      })
    }

    window.addEventListener('resize', handleResize)

    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return webpageSize
}
