import { useCallback, useState, useEffect } from 'react'
import { Iteration } from '../../types'

export const iterationId = (iteration: Iteration): string => {
  return `iteration-${iteration.idx}`
}

export const useIterationScrolling = ({
  iterations,
  isScrollOn,
  isClickOn,
}: {
  iterations: readonly Iteration[]
  isScrollOn: boolean
  isClickOn: boolean
}) => {
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )

  const handleIterationScroll = useCallback(
    (iteration) => {
      if (!isScrollOn) {
        return
      }

      setCurrentIteration(iteration)
    },
    [isScrollOn]
  )

  const handleIterationClick = useCallback(
    (iteration) => {
      setCurrentIteration(iteration)

      if (!isClickOn) {
        return
      }

      window.location.href = `#${iterationId(iteration)}`
    },
    [isClickOn]
  )

  return { currentIteration, handleIterationScroll, handleIterationClick }
}
