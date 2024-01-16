import React from 'react'
import { AutomationProps, Representations } from './Representation'

type RepresentationsWithoutFeedbackProps = {
  data: AutomationProps
}
export default function RepresentationsWithoutFeedback({
  data,
}: RepresentationsWithoutFeedbackProps): JSX.Element {
  return (
    <Representations
      {...data}
      trackCacheKey={['automation-without-feedback-track-cache-key']}
      selectedTab="without_feedback"
    />
  )
}
