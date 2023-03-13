import React from 'react'
import { FeedbackPanelProps } from '../FeedbackPanel'

export function PendingMentoringRequest({
  mentoringRequestLink,
}: Pick<FeedbackPanelProps, 'mentoringRequestLink'>): JSX.Element {
  return (
    <div className="flex flex-col">
      <h2 className="text-h5 mb-4">You&apos;ve requested mentoring</h2>
      <p className="text-p-base mb-8">Waiting on a mentor...</p>
      <a className="btn-primary btn-s mr-auto" href={mentoringRequestLink}>
        View your request
      </a>
    </div>
  )
}
