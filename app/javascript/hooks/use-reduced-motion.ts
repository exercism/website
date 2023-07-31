import { useEffect, useState } from 'react'

const reducedMotionMedia = window.matchMedia('(prefers-reduced-motion: reduce)')
export function useReducedMotion() {
  const [reducedMotion, setReducedMotion] = useState(
    () => reducedMotionMedia.matches
  )

  useEffect(() => {
    const onChange = (e) => setReducedMotion(e.matches)
    reducedMotionMedia.addEventListener('change', onChange)

    return () => {
      reducedMotionMedia.removeEventListener('change', onChange)
    }
  }, [])

  return reducedMotion
}
