import React from 'react'
import { RealtimeFeedbackModalProps } from '../../RealTimeFeedbackModal'
import { ContinueButton } from '../../components/FeedbackContentButtons'

export function NoImmediateFeedback({
  track,
  onContinue,
  onSendMentoringRequest,
}: Pick<RealtimeFeedbackModalProps, 'track'> &
  Record<'onContinue' | 'onSendMentoringRequest', () => void>): JSX.Element {
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-12">No Immediate Feedback</h3>

      <p className="text-16 leading-150 font-medium text-textColor1 mb-8">
        Our systems don&apos;t have any immediate suggestions about how to
        improve your code.
      </p>

      <p className="text-16 mb-16 leading-150">
        We recommend requesting code review from one of our {track.title}{' '}
        mentors. They&apos;ll give you feedback on your code and ideas about how
        you can make it even more idiomatic. It&apos;s 100% free 🙂
      </p>
      <div className="flex gap-12">
        <button onClick={onSendMentoringRequest} className="btn-primary btn-s">
          Request code review
        </button>
        <ContinueButton onClick={onContinue} className="btn-secondary" />
      </div>
    </div>
  )
}
