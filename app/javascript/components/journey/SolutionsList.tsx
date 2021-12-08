import React, { useState, useCallback, useEffect } from 'react'
import { SolutionProps, Solution } from './Solution'
import { Request } from '../../hooks/request-query'
import { useList } from '../../hooks/use-list'
import { removeEmpty, useHistory } from '../../hooks/use-history'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { Pagination, GraphicalIcon } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import { PaginatedResult } from '../types'
import { OrderSwitcher } from './solutions-list/OrderSwitcher'
import pluralize from 'pluralize'
import { SolutionFilter } from './solutions-list/SolutionFilter'

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
  const [criteria, setCriteria] = useState(request.query?.criteria || '')
  const cacheKey = [
    'contributions-list',
    request.endpoint,
    removeEmpty(request.query),
  ]
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult<SolutionProps[]>>(cacheKey, {
    ...request,
    query: removeEmpty(request.query),
    options: { ...request.options, enabled: isEnabled },
  })

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const setStatus = useCallback(
    (status) => {
      setQuery({ ...request.query, status: status, page: undefined })
    },
    [request.query, setQuery]
  )

  const setMentoringStatus = useCallback(
    (status) => {
      setQuery({ ...request.query, mentoringStatus: status, page: undefined })
    },
    [request.query, setQuery]
  )

  const setSyncStatus = useCallback(
    (status) => {
      setQuery({ ...request.query, syncStatus: status, page: undefined })
    },
    [request.query, setQuery]
  )

  const setTestsStatus = useCallback(
    (status) => {
      setQuery({ ...request.query, testsStatus: status, page: undefined })
    },
    [request.query, setQuery]
  )

  const setHeadTestsStatus = useCallback(
    (status) => {
      setQuery({ ...request.query, headTestsStatus: status, page: undefined })
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
    })
  }, [request.query, setQuery])

  return (
    <article className="solutions-tab theme-dark">
      <div className="md-container container">
        <div className="c-search-bar">
          <input
            className="--search"
            onChange={(e) => {
              setCriteria(e.target.value)
            }}
            value={criteria}
            placeholder="Search by exercise name"
          />
          <SolutionFilter
            status={request.query.status}
            mentoringStatus={request.query.mentoringStatus}
            syncStatus={request.query.syncStatus}
            testsStatus={request.query.testsStatus}
            headTestsStatus={request.query.headTestsStatus}
            setStatus={setStatus}
            setMentoringStatus={setMentoringStatus}
            setSyncStatus={setSyncStatus}
            setTestsStatus={setTestsStatus}
            setHeadTestsStatus={setHeadTestsStatus}
          />

          <OrderSwitcher
            value={(request.query.order || DEFAULT_ORDER) as Order}
            setValue={setOrder}
          />
        </div>
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
                  disabled={latestData === undefined}
                  current={request.query.page}
                  total={resolvedData.meta.totalPages}
                  setPage={setPage}
                />
              </React.Fragment>
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      </div>
    </article>
  )
}
