import React from 'react'
import { GraphicalIcon, Loading, Pagination } from '../common'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'

type PaginatedResult = {
  results: any[]
  meta: {
    current: number
    total: number
  }
}

type FilterType = {
  setFilter: (filter: string[]) => void
  value: string[]
}

type ResultsType = {
  sort: string
  setSort: (sort: string) => void
  results: any[]
}

export const SearchableList = ({
  endpoint,
  cacheKey,
  placeholder,
  FilterComponent,
  ResultsComponent,
}: {
  endpoint: string
  cacheKey: string
  placeholder: string
  FilterComponent: React.ComponentType<FilterType>
  ResultsComponent: React.ComponentType<ResultsType>
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setSearch, setFilter, setSort } = useList({
    endpoint: endpoint,
  })
  const { status, resolvedData, latestData } = usePaginatedRequestQuery<
    PaginatedResult
  >(cacheKey, request, isMountedRef)

  return (
    <div className="md-container container">
      <div className="c-search-bar">
        <input
          className="--search"
          onChange={(e) => {
            setSearch(e.target.value)
          }}
          value={request.query.search || ''}
          placeholder={placeholder}
        />
        <FilterComponent
          setFilter={setFilter}
          value={request.query.filter || []}
        />
        <button
          type="button"
          className="--reset-btn"
          onClick={() => setFilter([])}
        >
          <GraphicalIcon icon="reset" />
          Reset filters
        </button>
      </div>
      {status === 'loading' ? <Loading /> : null}
      {resolvedData ? (
        <ResultsComponent
          sort={request.query.sort}
          results={resolvedData.results}
          setSort={setSort}
        />
      ) : null}
      {latestData ? (
        <footer>
          <Pagination
            current={request.query.page}
            total={latestData.meta.total}
            setPage={setPage}
          />
        </footer>
      ) : null}
    </div>
  )
}
