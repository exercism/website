import React from 'react'
import { Pagination, FilterFallback } from '@/components/common/'
import { FetchingBoundary } from '../../FetchingBoundary'
import { APIResponse } from './useMentoringAutomation'
import { QueryStatus } from 'react-query'
import { AutomationListElement } from './AutomationListElement'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  page: number
  setPage: (page: number) => void
  withFeedback: boolean
}

export const RepresentationList = ({
  status,
  error,
  ...props
}: { status: QueryStatus; error: unknown } & Props): JSX.Element => {
  return (
    <FetchingBoundary
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    >
      <Component {...props} />
    </FetchingBoundary>
  )
}

function Component({
  resolvedData,
  latestData,
  page,
  setPage,
  withFeedback,
}: Props) {
  return (
    <>
      {resolvedData && resolvedData.results && (
        <React.Fragment>
          <div className="--solutions">
            {resolvedData.results.length > 0 ? (
              resolvedData.results.map((representation, key) => (
                <AutomationListElement
                  withFeedback={withFeedback}
                  key={key}
                  representation={representation}
                />
              ))
            ) : resolvedData.meta.unscopedTotal === 1 ? (
              <NoResultsYet />
            ) : (
              <NoResultsOfQuery />
            )}
          </div>
          <footer>
            <Pagination
              disabled={latestData === undefined}
              current={page}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </footer>
        </React.Fragment>
      )}
    </>
  )
}

function NoResultsOfQuery() {
  return (
    <FilterFallback
      icon="no-result-magnifier"
      title="No solutions found."
      description="Try changing your filters to find solutions that need feedback."
    />
  )
}

function NoResultsYet() {
  return (
    <FilterFallback
      icon="automation"
      svgFilter="filter-textColor6"
      title="There are currently no solutions that need feedback."
      description="Check back here later for more!"
    />
  )
}
