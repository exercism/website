import { useEffect, useState } from 'react'

/**
 *
 * @param second Timeout goal in seconds
 * @param callback Callback function
 * @returns [setStartTimer, setShouldRestart, timer, timeoutReached]
 *
 * - setStartTimer: A setter that starts the timer if set to `true`
 * - setShouldRestart: A setter that resets the timer if set to `true`
 * - timeoutReached: a boolean if timer reaches the goal
 * - timer: current state of the timer in second
 */
export function useTimeout(
  second: number,
  callback?: () => void
): [
  React.Dispatch<React.SetStateAction<boolean>>,
  React.Dispatch<React.SetStateAction<boolean>>,
  boolean,
  number
] {
  const [timer, setTimer] = useState(1)
  const [shouldRestart, setShouldRestart] = useState(false)
  const [timeoutReached, setTimeoutReached] = useState(false)
  const [startTimer, setStartTimer] = useState(false)

  useEffect(() => {
    let intervalId: NodeJS.Timer | null = null

    if (!timeoutReached && startTimer) {
      intervalId = setInterval(() => {
        setTimer((timer) => timer + 1)
      }, 1000)
    }

    if (timeoutReached && callback) {
      callback()
    }

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    return () => clearInterval(intervalId!)
  }, [callback, startTimer, timeoutReached])

  useEffect(() => {
    if (shouldRestart) {
      setTimer(1)
      setTimeoutReached(false)
      setShouldRestart(false)
    }
  }, [shouldRestart])

  useEffect(() => {
    if (timer >= second) {
      setTimeoutReached(true)
    }
  }, [second, timer])

  return [setStartTimer, setShouldRestart, timeoutReached, timer]
}
