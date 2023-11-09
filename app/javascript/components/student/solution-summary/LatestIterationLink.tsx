import React from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'
import { useLogger } from '@/hooks'

export default function LatestIterationLink({
  iteration,
}: {
  iteration: Iteration
}): JSX.Element {
  useLogger('iteration', iteration)
  return (
    <a className="iteration" href={iteration.links.self}>
      <IterationSummary
        iteration={iteration}
        showSubmissionMethod={true}
        showTestsStatusAsButton={false}
        showFeedbackIndicator={true}
      />
    </a>
  )
}
