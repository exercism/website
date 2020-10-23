import { useRef, useCallback, useEffect } from 'react'

export function useTimeout(handler: () => void, timeout: number, deps: any) {
  const timerRef = useRef<number | undefined>()
  const onTimeout = useCallback(() => {
    handler()
    timerRef.current = undefined
  }, [handler, timerRef])

  useEffect(() => {
    timerRef.current = window.setTimeout(onTimeout, timeout)
  }, deps)

  useEffect(() => {
    return () => {
      clearTimeout(timerRef.current)
    }
  }, [timerRef])
}
