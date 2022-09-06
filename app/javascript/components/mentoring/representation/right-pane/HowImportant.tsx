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
    <div className="px-24 overflow-auto">
      <h2 className="text-h4 mb-[10px]">How important is this?</h2>
      <RadioGroup
        feedbackType={feedbackType}
        setFeedbackType={setFeedbackType}
      />
    </div>
  )
}
