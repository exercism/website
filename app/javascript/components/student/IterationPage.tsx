import React, { useEffect } from 'react'
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

  if (!resolvedData) {
    return <Loading />
  }

  if (resolvedData.iterations.length === 0) {
    return <EmptyIterations links={links} />
  }

  return (
    <div className="lg-container container">
      <section className="iterations">
        {resolvedData.iterations.map((iteration, i) => {
          return (
            <IterationReport
              key={i}
              iteration={iteration}
              exercise={exercise}
              track={track}
              links={links}
              isOpen={i == 0}
            />
          )
        })}
      </section>
    </div>
  )
}
