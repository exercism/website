import { useState, useLayoutEffect } from 'react'
import FontFaceObserver from 'fontfaceobserver'

export function useFontLoaded(
  fontFamilyName: string,
  variant?: FontFaceObserver.FontVariant
): boolean | null {
  const [loadedCorrectly, setLoaded] = useState<boolean | null>(null)

  useLayoutEffect(() => {
    let hookMounted = true
    new FontFaceObserver(fontFamilyName, variant)
      .load()
      .then(() => {
        if (!hookMounted) {
          return
        }
        setLoaded(true)
      })
      .catch(() => {
        if (!hookMounted) {
          return
        }
        setLoaded(false)
      })
    return () => {
      hookMounted = false
    }
  }, [fontFamilyName, variant])

  return loadedCorrectly
}
