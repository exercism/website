import React from 'react'
import { Iteration } from '@/components/types'
import {
  default as IterationSummaryWithWebsockets,
  IterationSummary,
} from '@/components/track/IterationSummary'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Props = {
  iteration: Iteration
  isOutOfDate: boolean
}

export const IterationHeader = ({
  iteration,
  isOutOfDate,
}: Props): JSX.Element => {
  const { t } = useAppTranslation(
    'components/student/mentoring-session/iteration-view'
  )
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
  const { t } = useAppTranslation(
    'components/student/mentoring-session/iteration-view'
  )
  return (
    <GenericTooltip
      content={`
        ${t('iterationHeader.thisExerciseHasBeenUpdated')}
        ${t('iterationHeader.youCanUpdateToLatestVersion')}`}
    >
      <div>
        <IterationSummary.OutOfDateNotice />
      </div>
    </GenericTooltip>
  )
}
