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
  'track' | 'onClose' | 'open' | 'links' | 'trackObjectives' | 'mentoringStatus'
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
    case IterationStatus.DELETED:
    case IterationStatus.TESTS_FAILED:
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      return (
        <NoAutomatedFeedback
          links={links}
          mentoringStatus={mentoringStatus}
          onContinue={onContinue}
          track={track}
          trackObjectives={trackObjectives}
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
