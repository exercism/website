import React, { useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { RealtimeFeedbackModalProps } from '..'
import { ContinueButton } from './FeedbackContentButtons'
import { FeedbackMentoringRequestForm } from './FeedbackMentoringRequestForm'
import { MentorSessionRequest } from '@/components/types'

export function NoAutomatedFeedback({
  track,
  links,
  onContinue,
  trackObjectives,
}: { onContinue: () => void } & Pick<
  RealtimeFeedbackModalProps,
  'track' | 'trackObjectives' | 'links'
>): JSX.Element {
  const [sendingMentoringRequest, setSendingMentoringRequest] = useState(false)

  return (
    <div className="flex gap-40 items-start">
      {sendingMentoringRequest ? (
        <FeedbackMentoringRequestForm
          trackObjectives={trackObjectives}
          track={track}
          createMentorRequestLink={links.createMentorRequest}
          onContinue={onContinue}
          onSuccess={function (mentorRequest: MentorSessionRequest): void {
            throw new Error('Function not implemented.')
          }}
        />
      ) : (
        <NoImmediateFeedback
          track={track}
          onContinue={onContinue}
          onSendMentoringRequest={() => setSendingMentoringRequest(true)}
        />
      )}
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

function NoImmediateFeedback({
  track,
  onContinue,
  onSendMentoringRequest,
}: Pick<RealtimeFeedbackModalProps, 'track'> &
  Record<'onContinue' | 'onSendMentoringRequest', () => void>) {
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-12">No Immediate Feedback</h3>

      <p className="text-16 leading-150 font-medium text-textColor1 mb-8">
        Our systems don&apos;t have any immediate suggestions about your code.
      </p>

      <p className="text-16 mb-16 leading-150">
        We recommend sending the exercise to one of our {track.title} mentors.
        They&apos;ll give you feedback on your code and ideas about how you can
        make it even more idomatic. It&apos;s 100% free 🙂
      </p>
      <div className="flex gap-12">
        <button onClick={onSendMentoringRequest} className="btn-primary btn-s">
          Send to a mentor...
        </button>
        <ContinueButton onClick={onContinue} />
      </div>
    </div>
  )
}
