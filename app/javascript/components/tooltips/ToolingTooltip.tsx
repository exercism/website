import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'

const DEFAULT_ERROR = new Error('Unable to load data')

export type ToolingTooltipProps = {
  endpoint: string
}

export default function ToolingTooltip({
  endpoint,
}: ToolingTooltipProps): JSX.Element | null {
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-automation-locked-tooltip"
      loadingAlt="Loading data"
      defaultError={DEFAULT_ERROR}
    />
  )
}
