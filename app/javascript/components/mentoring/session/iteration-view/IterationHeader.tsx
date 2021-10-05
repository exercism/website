import React from 'react'
import { Iteration, File } from '../../../types'
import { DownloadButton } from './iteration-header/DownloadButton'
import { CopyButton } from './iteration-header/CopyButton'
import {
  IterationSummaryWithWebsockets,
  IterationSummary,
} from '../../../track/IterationSummary'
import { GenericTooltip } from '../../../misc/ExercismTippy'

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
        OutOfDateNotice={isOutOfDate ? <OutOfDateNotice /> : null}
        showTestsStatusAsButton={true}
        showFeedbackIndicator={false}
      />
      <DownloadButton command={downloadCommand} />
      {files ? <CopyButton files={files} /> : null}
    </header>
  )
}

const OutOfDateNotice = () => {
  return (
    <GenericTooltip
      content={`This exercise has been updated since the student submitted this
        iteration. It might not pass the most recent set of tests. Exercises
        can be updated by students by clicking on the yellow bar in the main
        exercise page.`}
    >
      <div>
        <IterationSummary.OutOfDateNotice />
      </div>
    </GenericTooltip>
  )
}
