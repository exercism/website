import React, { useState } from 'react'
import { Iteration } from '../Session'
import { IterationsList } from './IterationsList'
import { IterationFiles } from './IterationFiles'
import { IterationHeader } from './IterationHeader'
import { Icon } from '../../common/Icon'

export const IterationView = ({
  iterations,
  language,
}: {
  iterations: readonly Iteration[]
  language: string
}): JSX.Element => {
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )

  return (
    <React.Fragment>
      <IterationHeader
        iteration={currentIteration}
        latest={iterations[iterations.length - 1] === currentIteration}
      />
      <IterationFiles
        endpoint={currentIteration.links.files}
        language={language}
      />
      <footer className="discussion-footer">
        <IterationsList
          iterations={iterations}
          onClick={setCurrentIteration}
          current={currentIteration}
        />
        <button className="settings-button btn-keyboard-shortcut">
          <Icon icon="settings" alt="View settings" />
        </button>
      </footer>
    </React.Fragment>
  )
}
