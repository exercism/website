import React from 'react'
import { AutomationProps, Representations } from './Representation'

type RepresentationsWithFeedbackProps = {
  data: Omit<AutomationProps, 'withFeedback'>
}
export function RepresentationsWithFeedback({
  data,
}: RepresentationsWithFeedbackProps): JSX.Element {
  return <Representations withFeedback={true} {...data} />
}
