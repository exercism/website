import React, { useEffect } from 'react'
import { Header } from './solution-summary/Header'
import { IterationLink } from './solution-summary/IterationLink'
import { CommunitySolutions } from './solution-summary/CommunitySolutions'
import { Mentoring } from './solution-summary/Mentoring'
import { Nudge } from './solution-summary/Nudge'
import { Loading, ProminentLink } from '../common'
import { SolutionChannel } from '../../channels/solutionChannel'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { queryCache } from 'react-query'
import { Iteration, MentorDiscussion, SolutionForStudent } from '../types'

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

export type ExerciseType = 'concept' | 'practice' | 'tutorial'

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
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: Iteration[]
  }>(CACHE_KEY, request, isMountedRef)

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

  if (status === 'loading') {
    return <Loading />
  }

  if (!resolvedData) {
    return null
  }

  const latestIteration =
    resolvedData.iterations[resolvedData.iterations.length - 1]

  return (
    <>
      <Nudge
        status={solution.status}
        mentoringStatus={solution.mentoringStatus}
        track={track}
        discussions={discussions}
        iteration={latestIteration}
        exerciseType={exerciseType}
        links={links}
      />
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
          {exerciseType === 'tutorial' ? (
            <div className="next-steps">
              <div>
                This is where we’d usually link you to other peoples’ solutions
                to the same exercise.
              </div>
              <div>
                You also get the opportunity to be mentored by{' '}
                {solution.track.title} experts.
              </div>
            </div>
          ) : (
            <div className="next-steps">
              <CommunitySolutions link={links.communitySolutions} />
              <Mentoring
                mentoringStatus={solution.mentoringStatus}
                discussions={discussions}
                links={links}
              />
            </div>
          )}
        </section>
      ) : null}
    </>
  )
}
