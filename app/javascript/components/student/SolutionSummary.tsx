import React, { useEffect, useState } from 'react'
import { Header } from './solution-summary/Header'
import { IterationLink } from './solution-summary/IterationLink'
import { CommunitySolutions } from './solution-summary/CommunitySolutions'
import { Mentoring } from './solution-summary/Mentoring'
import { Loading, ProminentLink } from '../common'
import { SolutionChannel } from '../../channels/solutionChannel'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useQueryCache } from 'react-query'
import {
  Iteration,
  MentorDiscussion,
  SolutionForStudent,
  ExerciseType,
  IterationStatus,
} from '../types'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
  allIterations: string
  communitySolutions: string
  learnMoreAboutMentoringArticle: string
  mentoringInfo: string
  completeExercise: string
  shareMentoring: string
  requestMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export type SolutionSummaryRequest = {
  endpoint: string
  options: {
    initialData: {
      iterations: readonly Iteration[]
    }
  }
}

export type Track = {
  title: string
  medianWaitTime?: number
}

export type Exercise = {
  title: string
  type: ExerciseType
}

const REFETCH_INTERVAL = 2000

export const SolutionSummary = ({
  solution,
  track,
  discussions,
  request,
  exercise,
  links,
}: {
  solution: SolutionForStudent
  track: Track
  discussions: readonly MentorDiscussion[]
  request: SolutionSummaryRequest
  exercise: Exercise
  links: SolutionSummaryLinks
}): JSX.Element | null => {
  const queryCache = useQueryCache()
  const CACHE_KEY = `solution-${solution.uuid}-summary`
  const [queryEnabled, setQueryEnabled] = useState(true)
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: Iteration[]
  }>(CACHE_KEY, {
    ...request,
    options: {
      ...request.options,
      refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
    },
  })

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { uuid: solution.uuid },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, response)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, solution, queryCache])

  const latestIteration =
    resolvedData?.iterations[resolvedData?.iterations.length - 1]

  useEffect(() => {
    if (!latestIteration) {
      return
    }

    switch (latestIteration.status) {
      case IterationStatus.DELETED:
      case IterationStatus.UNTESTED:
      case IterationStatus.TESTING:
      case IterationStatus.ANALYZING:
        setQueryEnabled(true)
        break
      default:
        setQueryEnabled(false)
        break
    }
  }, [latestIteration])

  if (status === 'loading') {
    return <Loading />
  }

  if (!resolvedData) {
    return null
  }

  return (
    <>
      {latestIteration ? (
        <section className="latest-iteration">
          <Header
            iteration={latestIteration}
            exercise={exercise}
            links={links}
          />
          <IterationLink iteration={latestIteration} />
          <ProminentLink
            link={links.allIterations}
            text="See all of your iterations"
          />
          <div className="next-steps">
            <CommunitySolutions
              link={links.communitySolutions}
              isTutorial={exercise.type === 'tutorial'}
            />
            <Mentoring
              mentoringStatus={solution.mentoringStatus}
              discussions={discussions}
              links={links}
              isTutorial={exercise.type === 'tutorial'}
              trackTitle={track.title}
            />
          </div>
        </section>
      ) : null}
    </>
  )
}
