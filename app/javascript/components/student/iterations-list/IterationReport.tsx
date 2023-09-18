import React from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration, IterationStatus } from '../../types'
import { FilePanel } from '../../mentoring/session/FilePanel'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationsList'
import { GraphicalIcon } from '../../common'

export const IterationReport = ({
  iteration,
  exercise,
  track,
  links,
  isOpen,
  onExpanded,
  onCompressed,
  onDelete,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  isOpen: boolean
  onExpanded: () => void
  onCompressed: () => void
  onDelete: (iteration: Iteration) => void
}): JSX.Element => {
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
        <div className="deleted">This iteration has been deleted</div>
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
              onDelete={onDelete}
            />
          </div>
        </div>
      )}
    </details>
  )
}
