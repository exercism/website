import React, { useEffect, useState } from 'react'
import { Header } from './solution-summary/Header'
import { IterationLink } from './solution-summary/IterationLink'
import { CommunitySolutions } from './solution-summary/CommunitySolutions'
import { Mentoring } from './solution-summary/Mentoring'
import { Loading, ProminentLink } from '../common'
import { SolutionChannel } from '../../channels/solutionChannel'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { queryCache } from 'react-query'
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
  medianWaitTime: string
}

const REFETCH_INTERVAL = 2000

export const SolutionSummary = ({
  solution,
  track,
  discussions,
  request,
  exerciseType,
  links,
}: {
  solution: SolutionForStudent
  track: Track
  discussions: readonly MentorDiscussion[]
  request: SolutionSummaryRequest
  exerciseType: ExerciseType
  links: SolutionSummaryLinks
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const CACHE_KEY = `solution-${solution.id}-summary`
  const [queryEnabled, setQueryEnabled] = useState(true)
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: Iteration[]
  }>(
    CACHE_KEY,
    {
      ...request,
      options: {
        ...request.options,
        refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
      },
    },
    isMountedRef
  )

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { id: solution.id },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, response)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, solution])

  const latestIteration =
    resolvedData?.iterations[resolvedData?.iterations.length - 1]

  useEffect(() => {
    if (!latestIteration) {
      return
    }

    switch (latestIteration.status) {
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
            exerciseType={exerciseType}
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
              isTutorial={exerciseType === 'tutorial'}
            />
            <Mentoring
              mentoringStatus={solution.mentoringStatus}
              discussions={discussions}
              links={links}
              isTutorial={exerciseType === 'tutorial'}
              trackTitle={track.title}
            />
          </div>
        </section>
      ) : null}
    </>
  )
}
