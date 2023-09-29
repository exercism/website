import { useCallback, useState } from 'react'
import { Iteration } from '../../types'

export const iterationId = (iteration: Iteration): string => {
  return `iteration-${iteration.idx}`
}

export const useIterationScrolling = ({
  iterations,
  setIterations,
  on,
}: {
  iterations: readonly Iteration[]
  setIterations: React.Dispatch<React.SetStateAction<Iteration[]>>
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
    (iteration: Iteration) => {
      setCurrentIteration(iteration)
      if (iteration.new) {
        setIterations((iters: Iteration[]) => {
          return iters.map((iter) => {
            if (iter.idx === iteration.idx) {
              return { ...iter, new: false }
            }
            return iter
          })
        })
      }

      if (!on) {
        return
      }

      window.location.href = `#${iterationId(iteration)}`
    },
    [on]
  )

  return { currentIteration, handleIterationScroll, handleIterationClick }
}
