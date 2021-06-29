import { useState } from 'react'

export const useConfirmation = (toMatch: string) => {
  const [attempt, setAttempt] = useState('')

  return {
    attempt,
    setAttempt,
    isAttemptPass: attempt === toMatch,
  }
}
