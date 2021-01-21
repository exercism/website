import React, { useCallback } from 'react'
import { GraphicalIcon, Loading, Pagination } from '../common'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import { FilterPanel } from './searchable-list/FilterPanel'
import { ErrorBoundary, useErrorHandler } from '../ErrorBoundary'

type PaginatedResult = {
  results: any[]
  meta: {
    current: number
    total: number
  }
}

type ResultsType = {
  sort: string
  setSort: (sort: string) => void
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
  endpoint,
  cacheKey,
  placeholder,
  categories,
  ResultsComponent,
}: {
  endpoint: string
  cacheKey: string
  placeholder: string
  categories: FilterCategory[]
  ResultsComponent: React.ComponentType<ResultsType>
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setCriteria, setQuery, setSort } = useList({
    endpoint: endpoint,
  })
  const { status, resolvedData, latestData, error } = usePaginatedRequestQuery<
    PaginatedResult,
    Error | Response
  >(cacheKey, request, isMountedRef)

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
        <Results
          query={request.query}
          error={error}
          setSort={setSort}
          setPage={setPage}
          resolvedData={resolvedData}
          latestData={latestData}
          ResultsComponent={ResultsComponent}
        />
      </ErrorBoundary>
    </div>
  )
}

const Results = ({
  query,
  setSort,
  setPage,
  resolvedData,
  latestData,
  error,
  ResultsComponent,
}: {
  query: Record<string, any>
  setSort: (sort: string) => void
  setPage: (page: number) => void
  resolvedData: PaginatedResult | undefined
  latestData: PaginatedResult | undefined
  error: Error | Response | null
  ResultsComponent: React.ComponentType<ResultsType>
}) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return (
    <React.Fragment>
      {resolvedData ? (
        <ResultsComponent
          sort={query.sort}
          results={resolvedData.results}
          setSort={setSort}
        />
      ) : null}
      {latestData ? (
        <footer>
          <Pagination
            current={query.page}
            total={latestData.meta.total}
            setPage={setPage}
          />
        </footer>
      ) : null}
    </React.Fragment>
  )
}
