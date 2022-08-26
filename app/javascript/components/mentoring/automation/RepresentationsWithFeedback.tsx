import React from 'react'
import { AutomationProps, Representations } from './Representation'

export type RepresentationsWithFeedbackProps = {
  data: AutomationProps
}
export function RepresentationsWithFeedback({
  data,
}: RepresentationsWithFeedbackProps): JSX.Element {
  return <Representations {...data} withFeedback={true} />
}
