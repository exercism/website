// i18n-key-prefix: iterationReport
// i18n-namespace: components/student/iterations-list
import React from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration, IterationStatus } from '../../types'
import { FilePanel } from '../../mentoring/session/FilePanel'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationsList'
import { GraphicalIcon } from '../../common'
import { GithubSyncerSettings } from '@/components/settings/github-syncer/GitHubSyncerForm'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const IterationReport = ({
  iteration,
  exercise,
  track,
  links,
  isOpen,
  onExpanded,
  onCompressed,
  onDelete,
  syncer,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  isOpen: boolean
  onExpanded: () => void
  onCompressed: () => void
  onDelete: (iteration: Iteration) => void
  syncer: GithubSyncerSettings | null
}): JSX.Element => {
  const { t } = useAppTranslation()

  return (
    <details open={isOpen} className="iteration c-details">
      <summary
        className="header"
        role="button"
        onClick={(e) => {
          e.preventDefault()

          isOpen ? onCompressed() : onExpanded()
        }}
      >
        <div className="--summary-inner">
          <IterationSummary
            iteration={iteration}
            showSubmissionMethod={true}
            showTestsStatusAsButton={false}
            showFeedbackIndicator={true}
          />
          <div className="opener">
            <div className="--closed-icon">
              <GraphicalIcon icon="chevron-right" />
            </div>
            <div className="--open-icon">
              <GraphicalIcon icon="chevron-down" />
            </div>
          </div>
        </div>
      </summary>
      {iteration.status == IterationStatus.DELETED ? (
        <div className="deleted">
          {t('iterationReport.thisIterationHasBeenDeleted')}
        </div>
      ) : (
        <div className="content">
          <div className="files">
            {iteration.files ? (
              <FilePanel
                files={iteration.files}
                language={track.highlightjsLanguage}
                indentSize={track.indentSize}
                showCopyButton
              />
            ) : (
              <IterationFiles
                endpoint={iteration.links.files}
                language={track.highlightjsLanguage}
                indentSize={track.indentSize}
              />
            )}
          </div>
          <div className="information">
            <Information
              iteration={iteration}
              exercise={exercise}
              track={track}
              links={links}
              syncer={syncer}
              onDelete={onDelete}
            />
          </div>
        </div>
      )}
    </details>
  )
}
