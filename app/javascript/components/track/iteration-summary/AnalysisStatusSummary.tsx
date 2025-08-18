// i18n-key-prefix: analysisStatusSummary
// i18n-namespace: components/track/iteration-summary
import React from 'react'
import { Icon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function AnalysisStatusSummary({
  numEssentialAutomatedComments,
  numActionableAutomatedComments,
  numNonActionableAutomatedComments,
}: {
  numEssentialAutomatedComments: number
  numActionableAutomatedComments: number
  numNonActionableAutomatedComments: number
}): JSX.Element | null {
  const { t } = useAppTranslation('components/track/iteration-summary')
  if (
    numEssentialAutomatedComments === 0 &&
    numActionableAutomatedComments === 0 &&
    numNonActionableAutomatedComments === 0
  ) {
    return null
  }

  return (
    <div className="--feedback" role="status" aria-label="Analysis status">
      <Icon
        icon="automation"
        alt={t('analysisStatusSummary.automatedComments')}
      />

      {numEssentialAutomatedComments > 0 ? (
        <div
          className="--count --essential"
          title={t('analysisStatusSummary.essential')}
        >
          {numEssentialAutomatedComments}
        </div>
      ) : null}

      {numActionableAutomatedComments > 0 ? (
        <div
          className="--count --actionable"
          title={t('analysisStatusSummary.actionable')}
        >
          {numActionableAutomatedComments}
        </div>
      ) : null}

      {numNonActionableAutomatedComments > 0 ? (
        <div
          className="--count --non-actionable"
          title={t('analysisStatusSummary.other')}
        >
          {numNonActionableAutomatedComments}
        </div>
      ) : null}
    </div>
  )
}
