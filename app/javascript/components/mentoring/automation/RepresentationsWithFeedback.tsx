import React from 'react'
import { AutomationProps, Representations } from './Representation'

export function RepresentationsWithFeedback({
  data,
}: AutomationProps): JSX.Element {
  return <Representations withFeedback="true" {...data} data={data} />
}
