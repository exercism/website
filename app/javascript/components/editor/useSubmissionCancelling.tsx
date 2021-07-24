import { useState, useEffect } from 'react'

export const useSubmissionCancelling = (): [
  boolean,
  (hasCancelled: boolean) => void
] => {
  const [hasCancelled, setHasCancelled] = useState<boolean>(false)

  useEffect(() => {
    if (!hasCancelled) {
      return
    }

    const timer = setTimeout(() => setHasCancelled(false), 5000)

    return () => clearInterval(timer)
  }, [hasCancelled])

  return [hasCancelled, setHasCancelled]
}
