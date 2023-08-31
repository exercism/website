import React from 'react'
import { AutomationProps, Representations } from './Representation'

export type RepresentationsWithFeedbackProps = {
  data: AutomationProps
}
export default function RepresentationsWithFeedback({
  data,
}: RepresentationsWithFeedbackProps): JSX.Element {
  return (
    <Representations
      {...data}
      trackCacheKey={['automation-with-feedback-track-cache-key']}
      selectedTab="with_feedback"
    />
  )
}
