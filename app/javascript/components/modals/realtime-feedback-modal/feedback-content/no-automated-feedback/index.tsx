import React, { useCallback, useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { RealtimeFeedbackModalProps } from '../../RealTimeFeedbackModal'
import { FeedbackMentoringRequestForm } from './FeedbackMentoringRequestForm'
import { NoAutomatedFeedbackLHS } from './NoAutomatedFeedbackLHS'
import { NoImmediateFeedback } from './NoImmediateFeedback'
import { PendingMentoringRequest } from './PendingMentoringRequest'
import { InProgressMentoring } from './InProgressMentoring'
import { NoImmediateFeedbackNoAvailableMentoringSlot } from './NoImmediateFeedbackNoAvailableMentoringSlot'

export type NoFeedbackState =
  | 'initial'
  | 'sendingMentoringRequest'
  | RealtimeFeedbackModalProps['mentoringStatus']
export function NoAutomatedFeedback({
  track,
  links,
  onContinue,
  trackObjectives,
  mentoringStatus,
  hasAvailableMentoringSlot,
}: { onContinue: () => void } & Pick<
  RealtimeFeedbackModalProps,
  | 'track'
  | 'trackObjectives'
  | 'links'
  | 'mentoringStatus'
  | 'hasAvailableMentoringSlot'
>): JSX.Element {
  const [noFeedbackState, setNoFeedbackState] = useState<NoFeedbackState>(
    mentoringStatus === 'none' ? 'initial' : mentoringStatus
  )

  const handleSuccessfulMentorRequest = useCallback(() => {
    setNoFeedbackState('requested')
  }, [])

  return (
    <div className="flex gap-40 items-start">
      <NoAutomatedFeedbackLHS
        state={noFeedbackState}
        initialComponent={
          hasAvailableMentoringSlot ? (
            <NoImmediateFeedback
              track={track}
              onContinue={onContinue}
              onSendMentoringRequest={() =>
                setNoFeedbackState('sendingMentoringRequest')
              }
            />
          ) : (
            <NoImmediateFeedbackNoAvailableMentoringSlot
              onContinue={onContinue}
            />
          )
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
            onSuccess={handleSuccessfulMentorRequest}
          />
        }
        inProgressComponent={
          <InProgressMentoring
            mentorDiscussionLink={links.mentoringRequest}
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
