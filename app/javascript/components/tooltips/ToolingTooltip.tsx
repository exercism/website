import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type ToolingTooltipProps = {
  endpoint: string
}

export default function ToolingTooltip({
  endpoint,
}: ToolingTooltipProps): JSX.Element | null {
  const { t } = useAppTranslation('components/tooltips/ToolingTooltip.tsx')
  const DEFAULT_ERROR = new Error(t('toolingTooltip.unableToLoadData'))
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-automation-locked-tooltip"
      loadingAlt={t('toolingTooltip.loadingData')}
      defaultError={DEFAULT_ERROR}
    />
  )
}
