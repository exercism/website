import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'
import { ConceptTooltipSkeleton } from '../common/skeleton/skeletons/ConceptTooltipSkeleton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default function ConceptTooltip({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null {
  const { t } = useAppTranslation('components/tooltips/ConceptTooltip.tsx')
  const DEFAULT_ERROR = new Error(t('conceptTooltip.unableToLoadConcept'))
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-concept-tooltip"
      loadingAlt={t('conceptTooltip.loadingConceptData')}
      LoadingComponent={<ConceptTooltipSkeleton />}
      defaultError={DEFAULT_ERROR}
    />
  )
}
