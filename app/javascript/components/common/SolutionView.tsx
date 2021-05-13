import React, { useState } from 'react'
import { Iteration, File } from '../types'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { IterationsList } from '../mentoring/session/IterationsList'
import { FilePanel } from '../mentoring/session/FilePanel'
import { IterationSummaryWithWebsockets } from '../track/IterationSummary'
import { useIsMounted } from 'use-is-mounted'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { ChangeIterationButton } from './solution-view/ChangeIterationButton'

export type Links = {
  changeIteration?: string
}

const DEFAULT_ERROR = new Error('Unable to load files')

export const SolutionView = ({
  iterations,
  publishedIterationIdx,
  language,
  links,
}: {
  iterations: readonly Iteration[]
  publishedIterationIdx: number | null
  language: string
  links: Links
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
    <div className="c-solution-iterations">
      <IterationSummaryWithWebsockets iteration={currentIteration} />
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          error={error}
          status={status}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <FilePanel files={resolvedData.files} language={language} />
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
      <footer className="c-iterations-footer">
        {iterations.length > 1 ? (
          <IterationsList
            iterations={iterations}
            onClick={setCurrentIteration}
            current={currentIteration}
          />
        ) : null}
        {links.changeIteration ? (
          <ChangeIterationButton
            endpoint={links.changeIteration}
            publishedIterationIdx={publishedIterationIdx}
            iterations={iterations}
          />
        ) : null}
      </footer>
    </div>
  )
}
