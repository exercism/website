import { useState, useEffect, useCallback, createRef } from 'react'
import { Iteration } from '../../../types'

type IntersectionStatus = {
  iteration: Iteration
  isIntersecting: boolean
}

export type IterationWithRef = Iteration & {
  ref: React.RefObject<HTMLDivElement>
}

export const usePostScrolling = ({
  iterations,
  onScroll,
}: {
  iterations: readonly Iteration[]
  onScroll: (iteration: Iteration) => void
}): { iterationsWithRef: IterationWithRef[] } => {
  const [iterationsWithRef, setIterationsWithRef] = useState<
    IterationWithRef[]
  >([])
  const [intersectionStatus, setIntersectionStatus] = useState<
    IntersectionStatus[]
  >([])

  const registerEntry = useCallback(
    (entries: IntersectionObserverEntry[]) => {
      setIntersectionStatus(
        iterationsWithRef.map((i) => {
          const matchingEntry = entries.find((e) => e.target === i.ref.current)

          return {
            iteration: i,
            isIntersecting: matchingEntry
              ? matchingEntry.isIntersecting
              : false,
          }
        })
      )
    },
    [iterationsWithRef]
  )

  useEffect(() => {
    setIterationsWithRef(
      iterations.map((iteration) => {
        return { ...iteration, ref: createRef<HTMLDivElement>() }
      })
    )
  }, [JSON.stringify(iterations)])

  useEffect(() => {
    const observer = new IntersectionObserver(registerEntry, {
      threshold: 1,
      root: null,
      rootMargin: '0px',
    })

    iterationsWithRef.forEach((i) => {
      if (!i.ref.current) {
        return
      }

      observer.observe(i.ref.current)
    })

    return () => {
      observer.disconnect()
    }
  }, [iterationsWithRef, registerEntry])

  useEffect(() => {
    const intersectingIteration = intersectionStatus.filter(
      (s) => s.isIntersecting
    )[0]

    if (!intersectingIteration) {
      return
    }

    onScroll(intersectingIteration.iteration)
  }, [intersectionStatus, onScroll])

  return { iterationsWithRef }
}
