import React from 'react'
import {
  Iteration,
  IterationStatus,
  MentorDiscussion,
  File,
} from '../../../types'
import { IterationsList } from '../../session/IterationsList'
import { FilePanel } from '../../session/FilePanel'
import { IterationHeader } from '../../session/iteration-view/IterationHeader'
import { usePaginatedRequestQuery } from '../../../../hooks/request-query'
import { FetchingBoundary } from '../../../FetchingBoundary'
import { ResultsZone } from '../../../ResultsZone'
import { LinkButton } from '../../session/LinkButton'

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
  discussion,
  downloadCommand,
  // todo clean this up
  testData,
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
  discussion?: MentorDiscussion
  downloadCommand: string
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  testData: any
}): JSX.Element => {
  /* TODO: (required) Don't do this if currentIteration.links.files is null */
  const { resolvedData, error, status, isFetching } = usePaginatedRequestQuery<{
    files: readonly File[]
  }>(currentIteration.links.files, {
    endpoint: currentIteration.links.files,
    options: {},
  })

  return (
    <React.Fragment>
      <IterationHeader
        iteration={currentIteration}
        isOutOfDate={isOutOfDate}
        downloadCommand={downloadCommand}
        files={resolvedData?.files}
      />
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
                files={testData.examples[0]}
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
          {discussion ? (
            <LinkButton value={isLinked} setValue={setIsLinked} />
          ) : null}
        </footer>
      ) : null}
    </React.Fragment>
  )
}
