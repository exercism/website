import React from 'react'
import { Iteration, IterationStatus } from '../../types'
import { IterationsList } from './IterationsList'
import { FilePanel } from './FilePanel'
import { IterationHeader } from './IterationHeader'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { FetchingBoundary } from '../../FetchingBoundary'
import { File } from '../../types'
import { ResultsZone } from '../../ResultsZone'
import { LinkButton } from './LinkButton'

const DEFAULT_ERROR = new Error('Unable to load files')

export const IterationView = ({
  iterations,
  instructions,
  tests,
  currentIteration,
  onClick,
  language,
  indentSize,
  isOutOfDate,
  isLinked,
  setIsLinked,
}: {
  iterations: readonly Iteration[]
  instructions?: string
  tests?: string
  currentIteration: Iteration
  onClick: (iteration: Iteration) => void
  language: string
  indentSize: number
  isOutOfDate: boolean
  isLinked: boolean
  setIsLinked: (linked: boolean) => void
}): JSX.Element => {
  /* TODO: (required) Don't do this if currentIteration.links.files is null */
  const { resolvedData, error, status, isFetching } = usePaginatedRequestQuery<{
    files: File[]
  }>(currentIteration.links.files, {
    endpoint: currentIteration.links.files,
    options: {},
  })

  return (
    <React.Fragment>
      <IterationHeader iteration={currentIteration} isOutOfDate={isOutOfDate} />

      {currentIteration.status == IterationStatus.DELETED ? (
        <div className="deleted">This iteration has been deleted</div>
      ) : (
        <ResultsZone isFetching={isFetching}>
          <FetchingBoundary
            error={error}
            status={status}
            defaultError={DEFAULT_ERROR}
          >
            {resolvedData ? (
              <FilePanel
                files={resolvedData.files}
                language={language}
                indentSize={indentSize}
                instructions={instructions}
                tests={tests}
              />
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      )}
      {iterations.length > 1 ? (
        <footer className="c-iterations-footer">
          <IterationsList
            iterations={iterations}
            onClick={onClick}
            current={currentIteration}
          />
          <LinkButton value={isLinked} setValue={setIsLinked} />
        </footer>
      ) : null}
    </React.Fragment>
  )
}
