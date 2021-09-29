import React from 'react'
import { Iteration, File } from '../../../types'
import { DownloadButton } from './iteration-header/DownloadButton'
import { CopyButton } from './iteration-header/CopyButton'
import {
  IterationSummaryWithWebsockets,
  IterationSummary,
} from '../../../track/IterationSummary'

export type Props = {
  iteration: Iteration
  isOutOfDate: boolean
  downloadCommand: string
  files: readonly File[] | undefined
}

export const IterationHeader = ({
  iteration,
  isOutOfDate,
  downloadCommand,
  files,
}: Props): JSX.Element => {
  return (
    <header className="iteration-header">
      <IterationSummaryWithWebsockets
        iteration={iteration}
        showSubmissionMethod={false}
        OutOfDateNotice={
          isOutOfDate ? <IterationSummary.OutOfDateNotice /> : null
        }
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
      <DownloadButton command={downloadCommand} />
      {files ? <CopyButton files={files} /> : null}
    </header>
  )
}
