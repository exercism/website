import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'

const DEFAULT_ERROR = new Error('Unable to load concept')

export default function ConceptTooltip({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null {
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-concept-tooltip"
      loadingAlt="Loading concept data"
      defaultError={DEFAULT_ERROR}
    />
  )
}
