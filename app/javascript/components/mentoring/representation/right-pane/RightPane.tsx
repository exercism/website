import React, { useState } from 'react'
import {
  CompleteRepresentationData,
  RepresentationFeedbackType,
} from '../../../types'
import HowImportant from './HowImportant'
import MentoringConversation from './MentoringConversation'
import { UtilityTabs } from './UtilityTabs'

export function RightPane({
  data,
}: {
  data: CompleteRepresentationData
}): JSX.Element {
  const [feedbackType, setFeedbackType] = useState<RepresentationFeedbackType>(
    data.representation.feedbackType !== null
      ? data.representation.feedbackType
      : 'essential'
  )

  console.log(data)

  return (
    <div className="!h-100 py-16 flex flex-col justify-between">
      <div className="flex flex-col overflow-auto">
        <UtilityTabs data={data} />
        <HowImportant
          feedbackType={feedbackType}
          setFeedbackType={setFeedbackType}
        />
      </div>
      <MentoringConversation feedbackType={feedbackType} data={data} />
    </div>
  )
}
