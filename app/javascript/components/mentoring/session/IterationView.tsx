import React, { useState } from 'react'
import { Iteration } from '../../types'
import { IterationsList } from './IterationsList'
import { FilePanel } from './FilePanel'
import { IterationHeader } from './IterationHeader'
import { Icon } from '../../common/Icon'
import { useIsMounted } from 'use-is-mounted'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { FetchingBoundary } from '../../FetchingBoundary'
import { File } from '../../types'
import { ResultsZone } from '../../ResultsZone'

const DEFAULT_ERROR = new Error('Unable to load files')

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
  const isMountedRef = useIsMounted()
  const { resolvedData, error, status, isFetching } = usePaginatedRequestQuery<{
    files: File[]
  }>(
    currentIteration.links.files,
    { endpoint: currentIteration.links.files, options: {} },
    isMountedRef
  )

  return (
    <React.Fragment>
      <IterationHeader
        iteration={currentIteration}
        latest={iterations[iterations.length - 1] === currentIteration}
      />
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          error={error}
          status={status}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <FilePanel
              key={currentIteration.idx}
              files={resolvedData.files}
              language={language}
            />
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
      <footer className="discussion-footer">
        {iterations.length > 1 ? (
          <IterationsList
            iterations={iterations}
            onClick={setCurrentIteration}
            current={currentIteration}
          />
        ) : null}
        <button className="settings-button btn-keyboard-shortcut">
          <Icon icon="settings" alt="View settings" />
        </button>
      </footer>
    </React.Fragment>
  )
}
