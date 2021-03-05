import React, { useEffect } from 'react'
import { Header } from './solution-summary/Header'
import { IterationLink } from './solution-summary/IterationLink'
import { CommunitySolutions } from './solution-summary/CommunitySolutions'
import { Mentoring } from './solution-summary/Mentoring'
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
  isConceptExercise,
  links,
}: {
  solutionId: string
  request: SolutionSummaryRequest
  isConceptExercise: boolean
  links: SolutionSummaryLinks
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const CACHE_KEY = `solution-${solutionId}-summary`
  const { resolvedData } = usePaginatedRequestQuery<{
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

  if (!resolvedData) {
    return <Loading />
  }

  return (
    <section className="latest-iteration">
      <Header
        iteration={resolvedData.latestIteration}
        isConceptExercise={isConceptExercise}
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
  )
}
