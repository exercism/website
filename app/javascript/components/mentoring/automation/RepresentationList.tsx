import React from 'react'
import type { QueryStatus } from '@tanstack/react-query'
import { useScrollToTop } from '@/hooks'
import { Pagination, FilterFallback } from '@/components/common/'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { AutomationListElement } from './AutomationListElement'
import type { APIResponse } from './useMentoringAutomation'
import { SelectedTab } from './Representation'
import { scrollToTop } from '@/utils/scroll-to-top'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

type Props = {
  resolvedData: APIResponse | undefined
  page: number
  setPage: (page: number) => void
  withFeedback: boolean
  selectedTab: SelectedTab
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

function Component({ resolvedData, page, setPage, selectedTab }: Props) {
  return (
    <>
      {resolvedData && resolvedData.results && (
        <React.Fragment>
          <div className="--solutions">
            {resolvedData.results.length > 0 ? (
              resolvedData.results.map((representation, key) => (
                <AutomationListElement
                  selectedTab={selectedTab}
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
              disabled={resolvedData === undefined}
              current={page}
              total={resolvedData.meta.totalPages}
              setPage={(p) => {
                setPage(p)
                scrollToTop()
              }}
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
