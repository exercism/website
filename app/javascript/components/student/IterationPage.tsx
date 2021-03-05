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
  const [numIterationsExpanded, setNumIterationsExpanded] = useState(0)
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

  /* Only run this the first time that the component loads */
  useEffect(() => {
    setNumIterationsExpanded(
      resolvedData && resolvedData.iterations.length > 0 ? 1 : 0
    )
  }, [])

  if (!resolvedData) {
    return <Loading />
  }

  if (resolvedData.iterations.length === 0) {
    return <EmptyIterations links={links} />
  }

  useEffect(() => {
    console.log(numIterationsExpanded)
  }, [numIterationsExpanded])

  return (
    <div className="lg-container container">
      <section className="iterations">
        {resolvedData.iterations
          .slice()
          .sort((it1: Iteration, it2: Iteration) => {
            return it2.idx > it1.idx ? 1 : -1
          })
          .map((iteration, i) => {
            return (
              <IterationReport
                key={i}
                iteration={iteration}
                exercise={exercise}
                track={track}
                links={links}
                defaultIsOpen={i == 0}
                onExpanded={() => {
                  setNumIterationsExpanded((prev) => prev + 1)
                }}
                onCompressed={() => {
                  setNumIterationsExpanded((prev) => prev - 1)
                }}
              />
            )
          })}
      </section>
    </div>
  )
}
