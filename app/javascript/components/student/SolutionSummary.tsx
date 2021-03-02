import React from 'react'
import { Iteration } from '../types'
import { Header } from './solution-summary/Header'
import { IterationLink } from './solution-summary/IterationLink'
import { CommunitySolutions } from './solution-summary/CommunitySolutions'
import { Mentoring } from './solution-summary/Mentoring'
import { ProminentLink } from '../common'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
  allIterations: string
  communitySolutions: string
  learnMoreAboutMentoringArticle: string
}

export const SolutionSummary = ({
  iteration,
  isPracticeExercise,
  links,
}: {
  iteration: Iteration
  isPracticeExercise: boolean
  links: SolutionSummaryLinks
}): JSX.Element => {
  return (
    <section className="latest-iteration">
      <Header
        iteration={iteration}
        isPracticeExercise={isPracticeExercise}
        links={links}
      />
      <IterationLink iteration={iteration} />
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
