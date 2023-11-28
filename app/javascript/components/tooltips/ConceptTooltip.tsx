import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'
import { ConceptTooltipSkeleton } from '../common/skeleton/skeletons/ConceptTooltipSkeleton'

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
      LoadingComponent={<ConceptTooltipSkeleton />}
      defaultError={DEFAULT_ERROR}
    />
  )
}
