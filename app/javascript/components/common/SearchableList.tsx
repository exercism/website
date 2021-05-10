import React, { useCallback, useEffect } from 'react'
import { GraphicalIcon, Loading, Pagination } from '../common'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { FilterPanel } from './searchable-list/FilterPanel'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'
import { ResultsZone } from '../ResultsZone'

type PaginatedResult = {
  results: any[]
  meta: {
    currentPage: number
    totalPages: number
  }
}

type ResultsType = {
  order: string
  setOrder: (order: string) => void
  results: any[]
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

export const SearchableList = ({
  request: initialRequest,
  cacheKey,
  placeholder,
  categories,
  ResultsComponent,
  isEnabled = true,
}: {
  request: Request
  cacheKey: string
  placeholder: string
  categories: FilterCategory[]
  ResultsComponent: React.ComponentType<ResultsType>
  isEnabled?: boolean
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setCriteria, setQuery, setOrder } = useList(
    initialRequest
  )
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult, Error | Response>(
    [cacheKey, request.endpoint, request.query],
    {
      ...request,
      options: { ...request.options, enabled: isEnabled },
    },
    isMountedRef
  )

  const setFilter = useCallback(
    (filter) => {
      setQuery({ ...request.query, ...filter })
    },
    [request.query, setQuery]
  )

  return (
    <div className="md-container container">
      <div className="c-search-bar">
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={request.query.criteria || ''}
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
          <Results
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

const Results = ({
  query,
  setOrder,
  setPage,
  resolvedData,
  latestData,
  error,
  ResultsComponent,
}: {
  query: Record<string, any>
  setOrder: (order: string) => void
  setPage: (page: number) => void
  resolvedData: PaginatedResult | undefined
  latestData: PaginatedResult | undefined
  error: Error | Response | null
  ResultsComponent: React.ComponentType<ResultsType>
}) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  if (!resolvedData) {
    return null
  }

  return (
    <React.Fragment>
      <ResultsComponent
        order={query.order}
        results={resolvedData.results}
        setOrder={setOrder}
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
