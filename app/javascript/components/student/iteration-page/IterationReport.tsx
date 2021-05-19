import React, { useState, useEffect } from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'
import { FilePanel } from '../../mentoring/session/FilePanel'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationPage'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const IterationReport = ({
  iteration,
  exercise,
  track,
  links,
  isOpen,
  onExpanded,
  onCompressed,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  isOpen: boolean
  onExpanded: () => void
  onCompressed: () => void
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
            isLatest={false}
            showSubmissionMethod={true}
            showTestsStatusAsButton={false}
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
      <div className="content">
        <div className="files">
          {iteration.files ? (
            <FilePanel
              files={iteration.files}
              language={track.highlightJsLanguage}
            />
          ) : (
            <IterationFiles
              endpoint={iteration.links.files}
              language={track.highlightJsLanguage}
            />
          )}
        </div>
        <div className="information">
          <Information
            iteration={iteration}
            exercise={exercise}
            track={track}
            links={links}
          />
        </div>
      </div>
    </details>
  )
}
