import React from 'react'
import { RepresentationStatus, AnalysisStatus } from '../../types'
import { GraphicalIcon } from '../../common'
import { Icon } from '../../common/Icon'

export function AnalysisStatusSummary({
  numEssentialAutomatedComments,
  numActionableAutomatedComments,
  numNonActionableAutomatedComments,
}: {
  numEssentialAutomatedComments: number
  numActionableAutomatedComments: number
  numNonActionableAutomatedComments: number
}) {
  if (
    numEssentialAutomatedComments === 0 &&
    numActionableAutomatedComments === 0 &&
    numNonActionableAutomatedComments === 0
  ) {
    return null
  }

  return (
    <div className="--feedback" role="status" aria-label="Analysis status">
      {numEssentialAutomatedComments > 0 ? (
        <div className="--count --essential">
          <Icon icon="automation" alt="Essential automated comments" />
          {numEssentialAutomatedComments}
        </div>
      ) : null}

      {numActionableAutomatedComments > 0 ? (
        <div className="--count --actionable">
          <Icon icon="automation" alt="Recommended automated comments" />
          {numActionableAutomatedComments}
        </div>
      ) : null}

      {numNonActionableAutomatedComments > 0 ? (
        <div className="--count --non-actionable">
          <Icon icon="automation" alt="Other automated comments" />
          {numNonActionableAutomatedComments}
        </div>
      ) : null}
    </div>
  )
}
