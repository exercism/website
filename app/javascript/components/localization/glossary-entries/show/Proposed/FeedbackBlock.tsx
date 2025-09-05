import React from 'react'
import { LLMFeedback } from '.'

export function FeedbackBlock({ feedback }: { feedback: LLMFeedback }) {
  const isApproved = feedback.result === 'approved'

  return (
    <div className={`llm-feedback ${isApproved ? 'approved' : 'rejected'}`}>
      <div className={isApproved ? 'tick' : 'img'}>
        {isApproved ? '✅' : '❌'}
      </div>
      <div className="text">
        {feedback.reason}
        <div className="byline">This is automatically generated feedback.</div>
      </div>
    </div>
  )
}
