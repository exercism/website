import React from 'react'
import { AutomationProps, Representations } from './Representation'

type RepresentationsWithoutFeedbackProps = {
  data: Omit<AutomationProps, 'withFeedback'>
}
export function RepresentationsWithoutFeedback({
  data,
}: RepresentationsWithoutFeedbackProps): JSX.Element {
  return <Representations withFeedback={false} {...data} />
}
