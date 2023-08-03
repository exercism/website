import React, { useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { RealtimeFeedbackModalProps } from '../..'
import { FeedbackMentoringRequestForm } from './FeedbackMentoringRequestForm'
import { NoAutomatedFeedbackLHS } from './NoAutomatedFeedbackLHS'
import { NoImmediateFeedback } from './NoImmediateFeedback'
import { PendingMentoringRequest } from './PendingMentoringRequest'

export type NoFeedbackState =
  | 'initial'
  | 'sendingMentoringRequest'
  | 'pendingMentoringRequest'
export function NoAutomatedFeedback({
  track,
  links,
  onContinue,
  trackObjectives,
  mentoringRequested,
}: { onContinue: () => void } & Pick<
  RealtimeFeedbackModalProps,
  'track' | 'trackObjectives' | 'links' | 'mentoringRequested'
>): JSX.Element {
  const [noFeedbackState, setNoFeedbackState] = useState<NoFeedbackState>(
    mentoringRequested ? 'pendingMentoringRequest' : 'initial'
  )

  return (
    <div className="flex gap-40 items-start">
      <NoAutomatedFeedbackLHS
        state={noFeedbackState}
        initialComponent={
          <NoImmediateFeedback
            track={track}
            onContinue={onContinue}
            onSendMentoringRequest={() =>
              setNoFeedbackState('sendingMentoringRequest')
            }
          />
        }
        pendingComponent={
          <PendingMentoringRequest
            mentoringRequestLink={links.mentoringRequest}
            onContinue={onContinue}
          />
        }
        mentoringRequestFormComponent={
          <FeedbackMentoringRequestForm
            trackObjectives={trackObjectives}
            track={track}
            links={links}
            onContinue={onContinue}
          />
        }
      />
      <GraphicalIcon
        height={160}
        width={160}
        className="mb-16"
        icon="mentoring"
        category="graphics"
      />
    </div>
  )
}
