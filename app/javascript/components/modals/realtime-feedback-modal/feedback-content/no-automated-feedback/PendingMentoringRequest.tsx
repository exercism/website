import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'

export function PendingMentoringRequest({
  mentoringRequestLink,
  onContinue,
}: {
  mentoringRequestLink: string
  onContinue: () => void
}): JSX.Element {
  return (
    <div className="flex flex-col items-start">
      <h3 className="text-h4 mb-12">
        You&apos;ve submitted your solution for Code Review.
      </h3>

      <p className="text-16 mb-16 leading-150">
        A mentor will (hopefully) provide you with feedback soon. You&apos;ll
        recieve a notification and email when this happens.
      </p>
      <div className="flex gap-12">
        <a className="btn-primary btn-s mr-auto" href={mentoringRequestLink}>
          View your request
        </a>
        <ContinueButton onClick={onContinue} className="btn-secondary" />
      </div>
    </div>
  )
}
