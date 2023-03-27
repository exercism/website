import React from 'react'
import { IterationStatus } from '@/components/types'
import { CheckingForAutomatedFeedback } from './CheckingForAutomatedFeedback'
import { useTakingTooLong } from './useTakingTooLong'
import { NoAutomatedFeedback, FoundAutomatedFeedback } from './feedback-content'
import type {
  RealtimeFeedbackModalProps,
  ResolvedIteration,
} from '../RealtimeFeedbackModal'

export type FeedbackContentProps = {
  checkStatus: string
  continueAnyway: () => void
  latestIteration: ResolvedIteration | undefined
} & Pick<
  RealtimeFeedbackModalProps,
  | 'track'
  | 'exercise'
  | 'solution'
  | 'automatedFeedbackInfoLink'
  | 'mentorDiscussionsLink'
  | 'onClose'
  | 'open'
>

export function FeedbackContent({
  checkStatus,
  continueAnyway,
  open,
  exercise,
  track,
  automatedFeedbackInfoLink,
  mentorDiscussionsLink,
  latestIteration,
  onClose,
}: FeedbackContentProps): JSX.Element {
  const itIsTakingTooLong = useTakingTooLong(open)

  switch (checkStatus) {
    case 'loading':
      return (
        <CheckingForAutomatedFeedback
          onClick={continueAnyway}
          showTakingTooLong={itIsTakingTooLong}
        />
      )
    case IterationStatus.UNTESTED:
    case IterationStatus.NO_AUTOMATED_FEEDBACK:
      return (
        <NoAutomatedFeedback
          exercise={exercise}
          mentorDiscussionsLink={mentorDiscussionsLink}
          onContinue={continueAnyway}
          track={track}
        />
      )
    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
      return (
        <FoundAutomatedFeedback
          celebratory
          track={track}
          automatedFeedbackInfoLink={automatedFeedbackInfoLink}
          onClose={onClose}
          onContinue={continueAnyway}
          latestIteration={latestIteration}
        />
      )
    default:
      return (
        <FoundAutomatedFeedback
          track={track}
          automatedFeedbackInfoLink={automatedFeedbackInfoLink}
          onClose={onClose}
          onContinue={continueAnyway}
          latestIteration={latestIteration}
        />
      )
  }
}
