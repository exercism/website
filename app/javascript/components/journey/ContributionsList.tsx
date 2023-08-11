import React, { useState, useCallback, useEffect } from 'react'
import { ContributionResults } from './ContributionResults'
import {
  type Request,
  usePaginatedRequestQuery,
  useList,
  removeEmpty,
  useHistory,
  useDeepMemo,
  useScrollToTop,
} from '@/hooks'
import { ResultsZone } from '@/components/ResultsZone'
import { Pagination } from '@/components/common'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import type { Contribution } from '@/components/types'
import { CategorySelect } from './contributions-list/CategorySelect'

const DEFAULT_ERROR = new Error('Unable to load contributions list')

export type APIResult = {
  results: Contribution[]
  meta: {
    currentPage: number
    totalPages: number
    totalCount: number
    links: {
      markAllAsSeen: string
    }
    unseenTotal: number
  }
}

export const ContributionsList = ({
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
  } = useList(initialRequest)
  const [criteria, setCriteria] = useState(request.query?.criteria || '')
  const cacheKey = [
    'contributions-list',
    request.endpoint,
    removeEmpty(request.query),
  ]
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<APIResult>(cacheKey, {
      ...request,
      query: removeEmpty(request.query),
      options: { ...request.options, enabled: isEnabled },
    })

  const requestQuery = useDeepMemo(request.query)
  const setCategory = useCallback(
    (category) => {
      setQuery({ ...requestQuery, category: category, page: undefined })
    },
    [requestQuery, setQuery]
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const scrollToTopRef = useScrollToTop<HTMLDivElement>(requestQuery.page)

  return (
    <article className="reputation-tab theme-dark">
      <div className="md-container container">
        <div className="c-search-bar" ref={scrollToTopRef}>
          <input
            className="--search"
            onChange={(e) => {
              setCriteria(e.target.value)
            }}
            value={criteria}
            placeholder="Search by contribution name"
          />
          <CategorySelect
            value={request.query.category}
            setValue={setCategory}
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
                <ContributionResults data={resolvedData} cacheKey={cacheKey} />
                <Pagination
                  disabled={latestData === undefined}
                  current={request.query.page || 1}
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
