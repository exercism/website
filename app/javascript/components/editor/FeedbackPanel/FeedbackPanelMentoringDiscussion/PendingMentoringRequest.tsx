import React from 'react'
import { FeedbackPanelProps } from '../FeedbackPanel'

export function PendingMentoringRequest({
  mentoringRequestLink,
}: Pick<FeedbackPanelProps, 'mentoringRequestLink'>): JSX.Element {
  return (
    <div className="flex flex-col">
      <p className="text-p-base mb-8">
        <strong className="font-semibold text-textColor2">
          You&apos;ve submitted your solution for Code Review.
        </strong>{' '}
        A mentor will (hopefully) provide you with feedback soon. You&apos;ll
        recieve a notification and email when this happens.
      </p>
      <a className="btn-enhanced btn-s mr-auto" href={mentoringRequestLink}>
        View your request
      </a>
    </div>
  )
}
