import React, { SetStateAction } from 'react'
import { RepresentationFeedbackType } from '../../../types'
import RadioGroup from './RadioGroup'

export type HowImportantProps = {
  feedbackType: RepresentationFeedbackType
  setFeedbackType: React.Dispatch<SetStateAction<RepresentationFeedbackType>>
}

export default function HowImportant({
  feedbackType,
  setFeedbackType,
}: HowImportantProps): JSX.Element {
  return (
    <div className="mb-4">
      <h2 className="text-h6 mb-8">How important is this?</h2>
      <RadioGroup
        feedbackType={feedbackType}
        setFeedbackType={setFeedbackType}
      />
    </div>
  )
}
