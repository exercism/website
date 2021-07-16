import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'

const DEFAULT_ERROR = new Error('Unable to load taskk')

export const TaskTooltip = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null => {
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-task-tooltip"
      loadingAlt="Loading task data"
      defaultError={DEFAULT_ERROR}
    />
  )
}
