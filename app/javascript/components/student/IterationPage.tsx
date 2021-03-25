import React, { useEffect, useState } from 'react'
import { Loading } from '../common'
import { Iteration } from '../types'
import { IterationReport } from './iteration-page/IterationReport'
import { EmptyIterations } from './iteration-page/EmptyIterations'
import { useIsMounted } from 'use-is-mounted'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { SolutionChannel } from '../../channels/solutionChannel'
import { queryCache } from 'react-query'

export type Exercise = {
  title: string
}

export type Track = {
  title: string
  iconUrl: string
  highlightJsLanguage: string
}

export type Links = {
  getMentoring: string
  automatedFeedbackInfo: string
  startExercise: string
  solvingExercisesLocally: string
}

export type IterationPageRequest = {
  endpoint: string
  options: {
    initialData: {
      iterations: readonly Iteration[]
    }
  }
}

export const IterationPage = ({
  solutionId,
  request,
  exercise,
  track,
  links,
}: {
  solutionId: string
  request: IterationPageRequest
  exercise: Exercise
  track: Track
  links: Links
}): JSX.Element => {
  const [isOpen, setIsOpen] = useState<boolean[]>([])
  const isMountedRef = useIsMounted()
  const CACHE_KEY = `iterations-${track.title}-${exercise.title}`
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: readonly Iteration[]
  }>(CACHE_KEY, request, isMountedRef)

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { id: solutionId },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, { iterations: response.iterations })
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, solutionId])

  useEffect(() => {
    if (
      !resolvedData ||
      !resolvedData.iterations ||
      resolvedData.iterations.length === 0
    ) {
      return
    }

    if (isOpen.length === 0) {
      setIsOpen(
        resolvedData.iterations.map((iteration, i) => (i === 0 ? true : false))
      )

      return
    }

    const newIterationsLength = resolvedData.iterations.length - isOpen.length

    if (newIterationsLength > 0) {
      const newIsOpen = Array.from(Array(newIterationsLength)).map((_, i) =>
        i === 0 ? !isOpen.some((o) => o === true) : false
      )

      setIsOpen([...newIsOpen, ...isOpen])
    }
  }, [isOpen, isOpen.length, resolvedData])

  if (!resolvedData) {
    return <Loading />
  }

  if (resolvedData.iterations.length === 0) {
    return <EmptyIterations links={links} />
  }

  return (
    <div className="lg-container container">
      <section className="iterations">
        {resolvedData.iterations
          .slice()
          .sort((it1: Iteration, it2: Iteration) => {
            return it2.idx > it1.idx ? 1 : -1
          })
          .map((iteration, index) => {
            return (
              <IterationReport
                key={index}
                iteration={iteration}
                exercise={exercise}
                track={track}
                links={links}
                isOpen={isOpen[index]}
                onExpanded={() => {
                  setIsOpen(isOpen.map((o, i) => (index === i ? true : o)))
                }}
                onCompressed={() => {
                  setIsOpen(isOpen.map((o, i) => (index === i ? false : o)))
                }}
              />
            )
          })}
      </section>
    </div>
  )
}
