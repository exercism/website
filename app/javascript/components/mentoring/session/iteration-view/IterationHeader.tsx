import React, { useState, useEffect, useRef } from 'react'
import { Iteration, File } from '../../../types'
import { DownloadButton } from './iteration-header/DownloadButton'
import { CopyButton } from './iteration-header/CopyButton'
import { IterationSummaryWithWebsockets } from '../../../track/IterationSummary'

export const IterationHeader = ({
  iteration,
  isOutOfDate,
  downloadCommand,
  files,
}: {
  iteration: Iteration
  isOutOfDate: boolean
  downloadCommand: string
  files: readonly File[] | undefined
}): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        isOutOfDate={isOutOfDate}
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
      <DownloadButton command={downloadCommand} />
      {files ? <CopyButton files={files} /> : null}
    </header>
  )
}
