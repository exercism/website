import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'

export function InProgressMentoring({
  onContinue,
  mentorDiscussionLink,
}: {
  mentorDiscussionLink: string
  onContinue: () => void
}): JSX.Element {
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-8">
        You have a mentoring session active for this exercise.
      </h3>
      <p className="text-p-base mb-12">
        It is generally good practice to tell your mentor what you&apos;ve
        changed in your code and ask them to take a look at your new version.
      </p>

      <div className="flex gap-12">
        <a className="btn-primary btn-s mr-auto" href={mentorDiscussionLink}>
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
