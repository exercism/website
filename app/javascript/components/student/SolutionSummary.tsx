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
import { Iteration } from '../types'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
  allIterations: string
  communitySolutions: string
  learnMoreAboutMentoringArticle: string
  mentoringInfo: string
  completeExercise: string
}

export type SolutionSummaryRequest = {
  endpoint: string
  options: {
    initialData: {
      latestIteration: Iteration
    }
  }
}

export const SolutionSummary = ({
  solutionId,
  request,
  isPracticeExercise,
  links,
}: {
  solutionId: string
  request: SolutionSummaryRequest
  isPracticeExercise: boolean
  links: SolutionSummaryLinks
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const CACHE_KEY = `solution-${solutionId}-summary`
  const { resolvedData, status } = usePaginatedRequestQuery<{
    latestIteration: Iteration
  }>(CACHE_KEY, request, isMountedRef)

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { id: solutionId },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, response)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, solutionId])

  if (status === 'loading') {
    return <Loading />
  }

  if (!resolvedData) {
    return null
  }

  return (
    <React.Fragment>
      <Nudge
        iteration={resolvedData.latestIteration}
        isPracticeExercise={isPracticeExercise}
        links={links}
      />
      <section className="latest-iteration">
        <Header
          iteration={resolvedData.latestIteration}
          isPracticeExercise={isPracticeExercise}
          links={links}
        />
        <IterationLink iteration={resolvedData.latestIteration} />
        <ProminentLink
          link={links.allIterations}
          text="See all of your iterations"
        />
        <div className="next-steps">
          <CommunitySolutions link={links.communitySolutions} />
          <Mentoring link={links.learnMoreAboutMentoringArticle} />
        </div>
      </section>
    </React.Fragment>
  )
}
