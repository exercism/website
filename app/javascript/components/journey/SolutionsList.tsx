import React, { useState, useCallback, useEffect } from 'react'
import { SolutionResults } from './SolutionResults'
import { SolutionProps } from './Solution'
import { Request } from '../../hooks/request-query'
import { useList } from '../../hooks/use-list'
import { removeEmpty, useHistory } from '../../hooks/use-history'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { Pagination } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import { PaginatedResult } from '../types'
import { OrderSwitcher } from './solutions-list/OrderSwitcher'
import { ExerciseStatusSelect } from './solutions-list/ExerciseStatusSelect'
import { MentoringStatusSelect } from './solutions-list/MentoringStatusSelect'

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
      setQuery({ ...request.query, status: status })
    },
    [request.query, setQuery]
  )

  const setMentoringStatus = useCallback(
    (status) => {
      setQuery({ ...request.query, mentoringStatus: status })
    },
    [request.query, setQuery]
  )

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
          <ExerciseStatusSelect
            value={request.query.status}
            setValue={setStatus}
          />
          <MentoringStatusSelect
            value={request.query.mentoringStatus}
            setValue={setMentoringStatus}
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
                <SolutionResults data={resolvedData} />
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
