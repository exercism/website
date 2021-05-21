import React, { useState, useEffect } from 'react'
import { Iteration } from '../../types'
import { IterationSummaryWithWebsockets } from '../../track/IterationSummary'

export const IterationHeader = ({
  iteration,
  isLatest,
  isOutOfDate,
}: {
  iteration: Iteration
  isLatest: boolean
  isOutOfDate: boolean
}): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        isLatest={isLatest}
        isOutOfDate={isOutOfDate}
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
    </header>
  )
}
