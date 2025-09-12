// i18n-key-prefix: iterationHeader
// i18n-namespace: components/mentoring/session/iteration-view
import React from 'react'
import {
  default as IterationSummaryWithWebsockets,
  IterationSummary,
} from '@/components/track/IterationSummary'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { DownloadButton } from './iteration-header/DownloadButton'
import { CopyButton } from './iteration-header/CopyButton'
import type { Iteration, File } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation()
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
  const { t } = useAppTranslation()
  return (
    <GenericTooltip
      content={t('iterationHeader.outOfDateNotice.exerciseUpdated')}
    >
      <div>
        <IterationSummary.OutOfDateNotice />
      </div>
    </GenericTooltip>
  )
}
