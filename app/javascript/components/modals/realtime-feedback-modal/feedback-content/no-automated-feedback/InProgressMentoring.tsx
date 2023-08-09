import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'

export function InProgressMentoring({
  mentoringRequestLink,
  onContinue,
}: {
  mentoringRequestLink: string
  onContinue: () => void
}): JSX.Element {
  return (
    <div className="flex flex-col items-start h-[170px] justify-between">
      <h3 className="text-h4 mb-12">You have an ongoing mentoring session</h3>

      <div className="flex gap-12">
        <a className="btn-primary btn-s mr-auto" href={mentoringRequestLink}>
          Go to your discussion
        </a>
        <ContinueButton
          text="Continue to exercise"
          onClick={onContinue}
          className="btn-secondary"
        />
      </div>
    </div>
  )
}
