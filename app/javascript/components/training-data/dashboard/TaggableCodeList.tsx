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
  return (
    <div>
      {status === 'loading' && <Loading />}
      {status === 'error' && (
        <>
          <p>Something went wrong</p>
          <button onClick={() => refetch()} aria-label="Retry">
            Retry
          </button>
        </>
      )}
      {status === 'success' &&
        (resolvedData && resolvedData.results.length === 0 ? (
          <>
            <div className="--no-results">
              <GraphicalIcon icon="mentoring" category="graphics" />
              <h3>No training data</h3>
            </div>
          </>
        ) : (
          <div className="--conversations">
            {resolvedData && (
              <React.Fragment>
                {resolvedData.results.map((code, key) => (
                  <TaggableCode key={key} code={code} />
                ))}
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
              </React.Fragment>
            )}
          </div>
        ))}
    </div>
  )
}
