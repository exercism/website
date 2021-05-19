import React, { useState, useEffect } from 'react'
import { Iteration } from '../../types'
import { IterationSummaryWithWebsockets } from '../../track/IterationSummary'

export const IterationHeader = ({
  iteration,
  isLatest,
}: {
  iteration: Iteration
  isLatest: boolean
}): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        isLatest={isLatest}
        showTestsStatusAsButton={true}
      />
    </header>
  )
}
