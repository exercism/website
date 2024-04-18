import React from 'react'
import { ContinueButton } from '../../components/FeedbackContentButtons'

export function NoImmediateFeedbackNoAvailableMentoringSlot({
  onContinue,
}: Record<'onContinue', () => void>): JSX.Element {
  return (
    <div className="flex flex-col items-start self-stretch">
      <h3 className="text-h4 mb-12">No Immediate Feedback</h3>

      <p className="text-16 leading-150 font-medium text-textColor1 mb-auto">
        Our systems don&apos;t have any immediate suggestions about how to
        improve your code.
      </p>

      <ContinueButton onClick={onContinue} />
    </div>
  )
}
