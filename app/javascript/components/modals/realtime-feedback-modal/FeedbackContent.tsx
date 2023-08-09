import React from 'react'
import { IterationStatus } from '@/components/types'
import { useTakingTooLong } from './hooks'
import { CheckingForAutomatedFeedback } from './CheckingForAutomatedFeedback'
import { NoAutomatedFeedback, FoundAutomatedFeedback } from './feedback-content'
import type { RealtimeFeedbackModalProps, ResolvedIteration } from '.'

export type FeedbackContentProps = {
  checkStatus: string
  onContinue: () => void
  latestIteration: ResolvedIteration | undefined
} & Pick<
  RealtimeFeedbackModalProps,
  | 'track'
  | 'onClose'
  | 'open'
  | 'links'
  | 'trackObjectives'
  | 'mentoringStatus'
  | 'discussion'
>

export function FeedbackContent({
  checkStatus,
  onContinue,
  open,
  track,
  latestIteration,
  onClose,
  links,
  trackObjectives,
  mentoringStatus,
  discussion,
}: FeedbackContentProps): JSX.Element {
  const itIsTakingTooLong = useTakingTooLong(open)

  switch (checkStatus) {
    case 'loading':
      return (
        <CheckingForAutomatedFeedback
          onClick={onContinue}
          showTakingTooLong={itIsTakingTooLong}
        />
      )
    case IterationStatus.UNTESTED:
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      return (
        <NoAutomatedFeedback
          links={links}
          mentoringStatus={mentoringStatus}
          onContinue={onContinue}
          track={track}
          trackObjectives={trackObjectives}
          discussion={discussion}
        />
      )
    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
      return (
        <FoundAutomatedFeedback
          celebratory
          track={track}
          links={links}
          onClose={onClose}
          onContinue={onContinue}
          latestIteration={latestIteration}
        />
      )
    default:
      return (
        <FoundAutomatedFeedback
          track={track}
          links={links}
          onClose={onClose}
          onContinue={onContinue}
          latestIteration={latestIteration}
        />
      )
  }
}
