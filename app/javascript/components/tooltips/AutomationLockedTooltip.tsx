import React from 'react'
import { FetchedTooltip } from './FetchedTooltip'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type AutomationLockedTooltipProps = {
  endpoint: string
}

export default function AutomationLockedTooltip({
  endpoint,
}: AutomationLockedTooltipProps): JSX.Element | null {
  const { t } = useAppTranslation(
    'components/tooltips/AutomationLockedTooltip.tsx'
  )
  const DEFAULT_ERROR = new Error(t('automationLockedTooltip.unableToLoadData'))
  return (
    <FetchedTooltip
      endpoint={endpoint}
      className="c-automation-locked-tooltip"
      loadingAlt={t('automationLockedTooltip.loadingData')}
      defaultError={DEFAULT_ERROR}
    />
  )
}
