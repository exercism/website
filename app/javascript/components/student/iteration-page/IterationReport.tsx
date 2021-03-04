import React, { useState } from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationPage'
import { Accordion } from '../../common/Accordion'

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
  const [isOpen, setIsOpen] = useState(true)

  return (
    <Accordion
      id="notes"
      isOpen={isOpen}
      onClick={() => {
        setIsOpen(!isOpen)
      }}
    >
      <div className="iteration">
        <Accordion.Header label={`View iteration ${iteration.idx} details`}>
          <div className="header">
            <IterationSummary iteration={iteration} />
          </div>
        </Accordion.Header>
        <Accordion.Panel>
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
        </Accordion.Panel>
      </div>
    </Accordion>
  )
}
