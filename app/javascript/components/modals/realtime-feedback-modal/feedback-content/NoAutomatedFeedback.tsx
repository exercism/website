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
    <div className="flex flex-col items-center py-24">
      <h3 className="text-18 leading-regular font-semibold text-textColor1 mb-12 text-center ">
        There is no automated feedback for this exercise
      </h3>
      <GraphicalIcon
        height={120}
        width={120}
        className="mb-16"
        icon="mentoring"
        category="graphics"
      />
      <p className="text-16 mb-24 leading-huge text-center ">
        However, we recommend requesting a code review from one of our mentors
        for the {exercise.title} exercise to help improve your {track.title}{' '}
        skills.
      </p>
      <div className="flex gap-16">
        <a href={mentorDiscussionsLink} className="btn-secondary btn-s">
          Submit for a code review
        </a>
        <ContinueButton onClick={onContinue} />
      </div>
    </div>
  )
}
