import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { RealtimeFeedbackModalProps } from '../../RealtimeFeedbackModal'
import { ContinueButton } from './FeedbackContentButtons'

export function NoAutomatedFeedback({
  exercise,
  track,
  mentorDiscussionsLink,
  onContinue,
}: { onContinue: () => void } & Pick<
  RealtimeFeedbackModalProps,
  'exercise' | 'mentorDiscussionsLink' | 'track'
>): JSX.Element {
  return (
    <div className="flex gap-40 items-start">
      <div className="flex flex-col items-start">
        <h3 className="text-h4 mb-12">No Immediate Feedback</h3>

        <p className="text-16 leading-150 font-medium text-textColor1 mb-8">
          Our systems don't have any immediate suggestions about your code.
        </p>

        <p className="text-16 mb-16 leading-150">
          We recommend sending the exercise to one of our {track.title} mentors.
          They'll give you feedback on your code and ideas about how you can
          make it even more idomatic. It's 100% free 🙂
        </p>
        <div className="flex gap-12">
          <a href={mentorDiscussionsLink} className="btn-primary btn-s">
            Send to a mentor...
          </a>
          <ContinueButton onClick={onContinue} />
        </div>
      </div>
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
