import React from 'react'
import { RepresentationStatus, AnalysisStatus } from '../IterationSummary'
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
          <Icon icon="alert-circle" alt="Essential automated comments" />
          {numEssentialAutomatedComments}
        </div>
      ) : null}

      {numActionableAutomatedComments > 0 ? (
        <div className="--count --actionable">
          <Icon icon="info-circle" alt="Recommended automated comments" />
          {numActionableAutomatedComments}
        </div>
      ) : null}

      {numNonActionableAutomatedComments > 0 ? (
        <div className="--count --non-actionable">
          <Icon icon="automated-feedback" alt="Other automated comments" />
          {numNonActionableAutomatedComments}
        </div>
      ) : null}
    </div>
  )
}
