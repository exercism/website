import React, { useState, useEffect } from 'react'
import { scrollToTop } from '@/utils/scroll-to-top'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { ResultsZone } from '@/components/ResultsZone'
import { Pagination } from '@/components/common'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { BadgeResults } from './BadgeResults'
import { OrderSwitcher } from './badges-list/OrderSwitcher'
import type { PaginatedResult, Badge } from '@/components/types'
import type { QueryKey } from '@tanstack/react-query'

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
  const cacheKey: QueryKey = [
    'badges-list',
    request.endpoint,
    removeEmpty(request.query),
  ]
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult<Badge[]>>(cacheKey, {
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

  useEffect(() => {
    scrollToTop('badges-list', 0, 'smooth')
  }, [])

  return (
    <article
      data-scroll-top-anchor="badges-list"
      className="badges-tab theme-dark"
    >
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
                  disabled={resolvedData === undefined}
                  current={request.query.page || 1}
                  total={resolvedData.meta.totalPages}
                  setPage={(p) => {
                    setPage(p)
                    scrollToTop('badges-list')
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
