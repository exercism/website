import React from 'react'
import { AutomationProps, Representations } from './Representation'

export type RepresentationsWithFeedbackProps = {
  data: AutomationProps
}
export function RepresentationsAdmin({
  data,
}: RepresentationsWithFeedbackProps): JSX.Element {
  console.log(data)
  return (
    <Representations
      {...data}
      trackCacheKey="automation-admin-track-cache-key"
      selectedTab="admin"
    />
  )
}
