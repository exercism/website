import React, { useState } from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationPage'
import { Details } from '../../common/Details'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const IterationReport = ({
  iteration,
  exercise,
  track,
  links,
  isOpen,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  isOpen: boolean
}): JSX.Element => {
  return (
    <Details
      className="iteration"
      isOpen={isOpen}
      label={`Details of ${iteration.idx}`}
    >
      <Details.Summary className="header">
        <IterationSummary iteration={iteration} />
        <div className="opener">
          <div className="--closed-icon">
            <GraphicalIcon icon="chevron-right" />
          </div>
          <div className="--open-icon">
            <GraphicalIcon icon="chevron-down" />
          </div>
        </div>
      </Details.Summary>

      <div className="content">
        <div className="files">
          <IterationFiles
            endpoint={iteration.links.files}
            language={track.highlightJsLanguage}
          />
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
    </Details>
  )
}
