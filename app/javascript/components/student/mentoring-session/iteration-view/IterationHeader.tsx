import React from 'react'
import { Iteration } from '@/components/types'
import {
  default as IterationSummaryWithWebsockets,
  IterationSummary,
} from '@/components/track/IterationSummary'
import { GenericTooltip } from '@/components/misc/ExercismTippy'

export type Props = {
  iteration: Iteration
  isOutOfDate: boolean
}

export const IterationHeader = ({
  iteration,
  isOutOfDate,
}: Props): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        OutOfDateNotice={isOutOfDate ? <OutOfDateNotice /> : null}
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
    </header>
  )
}

const OutOfDateNotice = () => {
  return (
    <GenericTooltip
      content={`
        This exercise has been updated since this iteration was submitted.
        You can update to the latest version by clicking on the yellow bar at the top of the main exercise page.`}
    >
      <div>
        <IterationSummary.OutOfDateNotice />
      </div>
    </GenericTooltip>
  )
}
