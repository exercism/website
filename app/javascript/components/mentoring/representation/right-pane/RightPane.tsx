import React, { useState } from 'react'
import {
  CompleteRepresentationData,
  RepresentationFeedbackType,
} from '@/components/types'
import HowImportant from './HowImportant'
import MentoringConversation from './MentoringConversation'
import { UtilityTabs } from './UtilityTabs'

export function RightPane({
  data,
}: {
  data: CompleteRepresentationData
}): JSX.Element {
  const [feedbackType, setFeedbackType] = useState<RepresentationFeedbackType>(
    data.representation.feedbackType ||
      data.representation.draftFeedbackType ||
      'essential'
  )

  return (
    <div className="!h-100 flex flex-col justify-between">
      <UtilityTabs data={data} />
      <div className="comment-section --comment">
        <HowImportant
          feedbackType={feedbackType}
          setFeedbackType={setFeedbackType}
        />

        <MentoringConversation feedbackType={feedbackType} data={data} />
      </div>
    </div>
  )
}
