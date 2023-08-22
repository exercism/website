import React from 'react'
import { Icon } from '@/components/common'

export function AnalysisStatusSummary({
  numEssentialAutomatedComments,
  numActionableAutomatedComments,
  numNonActionableAutomatedComments,
}: {
  numEssentialAutomatedComments: number
  numActionableAutomatedComments: number
  numNonActionableAutomatedComments: number
}): JSX.Element | null {
  if (
    numEssentialAutomatedComments === 0 &&
    numActionableAutomatedComments === 0 &&
    numNonActionableAutomatedComments === 0
  ) {
    return null
  }

  return (
    <div className="--feedback" role="status" aria-label="Analysis status">
      <Icon icon="automation" alt="Automated comments" />

      {numEssentialAutomatedComments > 0 ? (
        <div className="--count --essential" title="Essential">
          {numEssentialAutomatedComments}
        </div>
      ) : null}

      {numActionableAutomatedComments > 0 ? (
        <div className="--count --actionable" title="Actionable">
          {numActionableAutomatedComments}
        </div>
      ) : null}

      {numNonActionableAutomatedComments > 0 ? (
        <div className="--count --non-actionable" title="Other">
          {numNonActionableAutomatedComments}
        </div>
      ) : null}
    </div>
  )
}
