import React, { useState, useEffect } from 'react'
import { Iteration } from '../../types'
import { IterationSummary } from '../../track/IterationSummary'

export const IterationHeader = ({
  iteration,
  isLatest,
}: {
  iteration: Iteration
  isLatest: boolean
}): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummary
        iteration={iteration}
        showSubmissionMethod={false}
        isLatest={isLatest}
        showTestsStatusAsButton={true}
      />
    </header>
  )
}
