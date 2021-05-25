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
      <Icon icon="automation" alt="Essential automated comments" />

      {numEssentialAutomatedComments > 0 ? (
        <div className="--count --essential">
          {numEssentialAutomatedComments}
        </div>
      ) : null}

      {numActionableAutomatedComments > 0 ? (
        <div className="--count --actionable">
          {numActionableAutomatedComments}
        </div>
      ) : null}

      {numNonActionableAutomatedComments > 0 ? (
        <div className="--count --non-actionable">
          {numNonActionableAutomatedComments}
        </div>
      ) : null}
    </div>
  )
}
