import React, { useCallback, useState, useEffect } from 'react'
import { QueryKey } from '@tanstack/react-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { useDeepMemo } from '@/hooks/use-deep-memo'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { GraphicalIcon, Loading, Pagination } from '@/components/common'
import { FilterPanel } from './searchable-list/FilterPanel'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import type { PaginatedResult } from '@/components/types'

type ResultsType<T> = {
  order: string
  setOrder: (order: string) => void
  data: T
  cacheKey: QueryKey
}

export type FilterCategory = {
  value: string
  label: string
  options: {
    value: string
    label: string
  }[]
}

export type FilterValue = Record<string, string>

const DEFAULT_ERROR = new Error('Unable to fetch list')

export const SearchableList = <
  T extends unknown,
  U extends PaginatedResult<T>
>({
  request: initialRequest,
  cacheKey: cacheKeyPrefix,
  placeholder,
  categories,
  ResultsComponent,
  isEnabled = true,
}: {
  request: Request
  cacheKey: string
  placeholder: string
  categories: FilterCategory[]
  ResultsComponent: React.ComponentType<ResultsType<U>>
  isEnabled?: boolean
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
    cacheKeyPrefix,
    request.endpoint,
    removeEmpty(request.query),
  ]
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<U, Error | Response>(cacheKey, {
      ...request,
      query: removeEmpty(request.query),
      options: { ...request.options, enabled: isEnabled },
    })

  const requestQuery = useDeepMemo(request.query)
  const setFilter = useCallback(
    (filter) => {
      setQuery({ ...requestQuery, ...filter })
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

  return (
    <div className="md-container container">
      <div className="c-search-bar">
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={criteria}
          placeholder={placeholder}
        />
        <FilterPanel
          setFilter={setFilter}
          categories={categories}
          value={request.query.filter || {}}
        />
        <button
          type="button"
          className="--reset-btn"
          onClick={() => setFilter({})}
        >
          <GraphicalIcon icon="reset" />
          Reset filters
        </button>
      </div>
      {status === 'loading' ? <Loading /> : null}
      <ErrorBoundary>
        <ResultsZone isFetching={isFetching}>
          <Results<T, U>
            cacheKey={cacheKey}
            query={request.query}
            error={error}
            setOrder={setOrder}
            setPage={setPage}
            resolvedData={resolvedData}
            latestData={latestData}
            ResultsComponent={ResultsComponent}
          />
        </ResultsZone>
      </ErrorBoundary>
    </div>
  )
}

const Results = <T extends unknown, U extends PaginatedResult<T>>({
  query,
  cacheKey,
  setOrder,
  setPage,
  resolvedData,
  latestData,
  error,
  ResultsComponent,
}: {
  cacheKey: QueryKey
  query: Record<string, any>
  setOrder: (order: string) => void
  setPage: (page: number) => void
  resolvedData: U | undefined
  latestData: U | undefined
  error: Error | Response | null
  ResultsComponent: React.ComponentType<ResultsType<U>>
}) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  if (!resolvedData) {
    return null
  }

  return (
    <React.Fragment>
      <ResultsComponent
        order={query.order}
        data={resolvedData}
        setOrder={setOrder}
        cacheKey={cacheKey}
      />
      <Pagination
        disabled={latestData === undefined}
        current={query.page}
        total={resolvedData.meta.totalPages}
        setPage={setPage}
      />
    </React.Fragment>
  )
}
