import { useEffect } from 'react'
import { useTimeout } from '@/hooks'

const BROADCAST_TIMEOUT_IN_SECONDS = 10
export function useTakingTooLong(open: boolean): boolean {
  const [startTimer, restartTimer, itIsTakingTooLong] = useTimeout(
    BROADCAST_TIMEOUT_IN_SECONDS
  )

  useEffect(() => {
    if (open) startTimer(true)
    else {
      startTimer(false)
      restartTimer(true)
    }
  }, [open, restartTimer, startTimer])

  return itIsTakingTooLong
}
