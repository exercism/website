import React from 'react'
import {
  QueryObserverResult,
  QueryStatus,
  RefetchQueryFilters,
} from '@tanstack/react-query'
import { Pagination, Loading, GraphicalIcon } from '@/components/common'
import { TaggableCode } from './TaggableCode'
import { scrollToTop } from '@/utils/scroll-to-top'
import { TrainingDataRequestAPIResponse } from './Dashboard.types'
import type { RefetchOptions } from 'react-query/types/core/query'

export const TaggableCodeList = ({
  resolvedData,
  refetch,
  status,
  setPage,
}: {
  resolvedData: TrainingDataRequestAPIResponse | undefined
  status: QueryStatus
  setPage: (page: number) => void
  refetch: <TPageData>(
    options?: (RefetchOptions & RefetchQueryFilters<TPageData>) | undefined
  ) => Promise<QueryObserverResult<TrainingDataRequestAPIResponse, unknown>>
}): JSX.Element => {
  const noResults = resolvedData && resolvedData.results.length === 0

  const SuccessContent = () => {
    if (noResults)
      return (
        <div className="--no-results">
          <GraphicalIcon icon="mentoring" category="graphics" />
          <h3>No training data</h3>
        </div>
      )
    return (
      <div className="--conversations">
        {resolvedData && (
          <React.Fragment>
            {resolvedData.results.map((code, key) => (
              <TaggableCode key={key} code={code} />
            ))}
            {resolvedData.meta.totalPages > 1 && (
              <footer>
                <Pagination
                  disabled={resolvedData === undefined}
                  current={resolvedData.meta.currentPage}
                  total={resolvedData.meta.totalPages}
                  setPage={(p) => {
                    setPage(p)
                    scrollToTop()
                  }}
                />
              </footer>
            )}
          </React.Fragment>
        )}
      </div>
    )
  }

  switch (status) {
    case 'loading':
      return <Loading />
    case 'error':
      return <SomethingWentWrongWithRefetch refetch={refetch} />
    case 'success':
      return <SuccessContent />
  }
}

// TODO: Turn this into a common/global component
function SomethingWentWrongWithRefetch({ refetch }) {
  return (
    <div className="flex flex-col gap-32 p-32 place-items-center">
      <h3 className="text-h3">Oops! Something went wrong!</h3>
      <GraphicalIcon icon="error-404" width={50} height={50} />
      <button
        className="btn-m btn-default"
        onClick={() => refetch()}
        aria-label="Retry"
      >
        Retry
      </button>
    </div>
  )
}
