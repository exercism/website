import React from 'react'
import { Iteration } from '../../types'
import { IterationsList } from './IterationsList'
import { FilePanel } from './FilePanel'
import { IterationHeader } from './IterationHeader'
import { useIsMounted } from 'use-is-mounted'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { FetchingBoundary } from '../../FetchingBoundary'
import { File } from '../../types'
import { ResultsZone } from '../../ResultsZone'
import { SettingsButton } from './SettingsButton'
import { Settings } from '../Session'

const DEFAULT_ERROR = new Error('Unable to load files')

export const IterationView = ({
  iterations,
  currentIteration,
  onClick,
  language,
  indentSize,
  isOutOfDate,
  settings,
  setSettings,
}: {
  iterations: readonly Iteration[]
  currentIteration: Iteration
  onClick: (iteration: Iteration) => void
  language: string
  indentSize: number
  isOutOfDate: boolean
  settings: Settings
  setSettings: (settings: Settings) => void
}): JSX.Element => {
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
        isLatest={iterations[iterations.length - 1] === currentIteration}
        isOutOfDate={isOutOfDate}
      />
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
            />
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
      <footer className="c-iterations-footer">
        {iterations.length > 1 ? (
          <IterationsList
            iterations={iterations}
            onClick={onClick}
            current={currentIteration}
          />
        ) : null}
        <SettingsButton value={settings} setValue={setSettings} />
      </footer>
    </React.Fragment>
  )
}
