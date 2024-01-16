import React, { useState, useCallback, useEffect } from 'react'
import pluralize from 'pluralize'
import { scrollToTop } from '@/utils/scroll-to-top'
import { SolutionProps, Solution } from './Solution'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { removeEmpty, useHistory } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { ResultsZone } from '@/components/ResultsZone'
import { Pagination, GraphicalIcon } from '@/components/common'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import {
  MentoringStatus,
  SyncStatus,
  TestsStatus,
  HeadTestsStatus,
  SolutionFilter,
  OrderSwitcher,
  ExerciseStatus,
} from './solutions-list'
import type { PaginatedResult } from '@/components/types'

export type Order = 'newest_first' | 'oldest_first'

const DEFAULT_ORDER = 'newest_first'
const DEFAULT_ERROR = new Error('Unable to load solutions')

export const SolutionsList = ({
  request: initialRequest,
  isEnabled,
}: {
  request: Request
  isEnabled: boolean
}): JSX.Element => {
  const {
    request,
    setPage,
    setCriteria: setRequestCriteria,
    setQuery,
    setOrder,
  } = useList(initialRequest)
  const [criteria, setCriteria] = useState(request.query?.criteria)
  const cacheKey = [
    'contributions-list',
    request.endpoint,
    removeEmpty(request.query),
  ]
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult<SolutionProps[]>>(cacheKey, {
    ...request,
    query: removeEmpty(request.query),
    options: { ...request.options, enabled: isEnabled },
  })

  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria === undefined || criteria === null) return
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const handleApply = useCallback(
    (
      status: ExerciseStatus,
      mentoringStatus: MentoringStatus,
      syncStatus: SyncStatus,
      testsStatus: TestsStatus,
      headTestsStatus: HeadTestsStatus
    ) => {
      setQuery({
        ...request.query,
        page: undefined,
        status: status,
        mentoringStatus: mentoringStatus,
        syncStatus: syncStatus,
        testsStatus: testsStatus,
        headTestsStatus: headTestsStatus,
      })
    },
    [request.query, setQuery]
  )

  const handleReset = useCallback(() => {
    setQuery({
      ...request.query,
      page: undefined,
      status: undefined,
      mentoringStatus: undefined,
      syncStatus: undefined,
      testsStatus: undefined,
      headTestsStatus: undefined,
    })
  }, [request.query, setQuery])

  return (
    <article
      data-scroll-top-anchor="solutions-list"
      className="solutions-tab theme-dark"
    >
      <div className="c-search-bar">
        <div className="md-container container">
          <input
            className="--search"
            onChange={(e) => {
              setCriteria(e.target.value)
            }}
            value={criteria || ''}
            placeholder="Search by exercise or track name"
          />
          <SolutionFilter request={request} onApply={handleApply} />
          <OrderSwitcher
            value={(request.query.order || DEFAULT_ORDER) as Order}
            setValue={setOrder}
          />
        </div>
      </div>
      <div className="md-container container">
        <ResultsZone isFetching={isFetching}>
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
          >
            {resolvedData ? (
              <React.Fragment>
                <div>
                  <div className="results-title-bar">
                    <h3>
                      Showing {resolvedData.meta.totalCount}{' '}
                      {pluralize('solution', resolvedData.meta.totalCount)}
                    </h3>
                    <button
                      type="button"
                      onClick={handleReset}
                      className="btn-link"
                    >
                      <GraphicalIcon icon="reset" />
                      <span>Reset filters</span>
                    </button>
                  </div>
                  <div className="solutions">
                    {resolvedData.results.map((solution) => {
                      return <Solution {...solution} key={solution.uuid} />
                    })}
                  </div>
                </div>
                <Pagination
                  disabled={resolvedData === undefined}
                  current={request.query.page || 1}
                  total={resolvedData.meta.totalPages}
                  setPage={(p) => {
                    setPage(p)
                    scrollToTop('solutions-list')
                  }}
                />
              </React.Fragment>
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </div>
    </article>
  )
}
