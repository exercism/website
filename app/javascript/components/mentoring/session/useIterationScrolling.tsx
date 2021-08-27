import { useCallback, useState } from 'react'
import { Iteration } from '../../types'

export const iterationId = (iteration: Iteration): string => {
  return `iteration-${iteration.idx}`
}

export const useIterationScrolling = ({
  iterations,
  on,
}: {
  iterations: readonly Iteration[]
  on: boolean
}) => {
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )

  const handleIterationScroll = useCallback(
    (iteration) => {
      if (!on) {
        return
      }

      setCurrentIteration(iteration)
    },
    [on]
  )

  const handleIterationClick = useCallback(
    (iteration) => {
      setCurrentIteration(iteration)

      if (!on) {
        return
      }

      window.location.href = `#${iterationId(iteration)}`
    },
    [on]
  )

  return { currentIteration, handleIterationScroll, handleIterationClick }
}
