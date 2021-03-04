import React from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationPage'

export const IterationReport = ({
  iteration,
  exercise,
  track,
  links,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
}): JSX.Element => {
  return (
    <div className="iteration">
      <div className="header">
        <IterationSummary iteration={iteration} />
      </div>
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
    </div>
  )
}
