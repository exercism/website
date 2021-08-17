import React, { useState, useEffect } from 'react'
import { BadgeResults } from './BadgeResults'
import { Request } from '../../hooks/request-query'
import { useList } from '../../hooks/use-list'
import { removeEmpty, useHistory } from '../../hooks/use-history'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { ResultsZone } from '../ResultsZone'
import { Pagination } from '../common'
import { FetchingBoundary } from '../FetchingBoundary'
import { OrderSwitcher } from './badges-list/OrderSwitcher'
import { PaginatedResult, Badge } from '../types'

const DEFAULT_ORDER = 'unrevealed_first'
const DEFAULT_ERROR = new Error('Unable to load badge list')

export const BadgesList = ({
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
    setOrder,
  } = useList(initialRequest)
  const [criteria, setCriteria] = useState(request.query?.criteria || '')
  const cacheKey = ['badges-list', request.endpoint, removeEmpty(request.query)]
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult<Badge[]>>(cacheKey, {
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

  return (
    <article className="badges-tab theme-dark">
      <div className="md-container container">
        <div className="c-search-bar">
          <input
            className="--search"
            onChange={(e) => {
              setCriteria(e.target.value)
            }}
            value={criteria}
            placeholder="Search by badge name or description"
          />
          <OrderSwitcher
            value={request.query.order || DEFAULT_ORDER}
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
                <BadgeResults data={resolvedData} cacheKey={cacheKey} />
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
