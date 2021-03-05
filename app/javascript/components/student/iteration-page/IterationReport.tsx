import React, { useState, useEffect } from 'react'
import { IterationSummary } from '../../track/IterationSummary'
import { Iteration } from '../../types'
import { IterationFiles } from '../../mentoring/session/IterationFiles'
import { Information } from './Information'
import { Exercise, Track, Links } from '../IterationPage'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const IterationReport = ({
  iteration,
  exercise,
  track,
  links,
  defaultIsOpen,
  onExpanded,
  onCompressed,
}: {
  iteration: Iteration
  exercise: Exercise
  track: Track
  links: Links
  defaultIsOpen: boolean
  onExpanded: () => void
  onCompressed: () => void
}): JSX.Element => {
  const [isOpen, setIsOpen] = useState(defaultIsOpen)

  useEffect(() => {
    if (isOpen) {
      onExpanded()
    } else {
      onCompressed()
    }
  }, [isOpen])

  return (
    <details open={defaultIsOpen} className="iteration c-details">
      <summary
        className="header"
        role="button"
        onClick={() => {
          setIsOpen((prev) => !prev)
        }}
      >
        <IterationSummary iteration={iteration} />
        <div className="opener">
          <div className="--closed-icon">
            <GraphicalIcon icon="chevron-right" />
          </div>
          <div className="--open-icon">
            <GraphicalIcon icon="chevron-down" />
          </div>
        </div>
      </summary>
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
    </details>
  )
}
