import React from 'react'
import { GraphicalIcon, Loading, Pagination } from '../common'
import { SolutionProps, Solution } from './Solution'
import { SolutionFilter } from './SolutionFilter'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useList } from '../../hooks/use-list'
import pluralize from 'pluralize'

type PaginatedResult<T> = {
  results: T[]
  meta: {
    current: number
    total: number
  }
}

export type SolutionFilterOption = {
  value: string
  title: string
}

const FILTERS: SolutionFilterOption[] = [
  {
    value: 'oop',
    title: 'OOP',
  },
  {
    value: 'functional',
    title: 'Functional',
  },
]

export const SolutionsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setSearch, setFilter, setSort } = useList(
    initialRequest
  )
  const { status, resolvedData, latestData } = usePaginatedRequestQuery<
    PaginatedResult<SolutionProps>
  >('journey-solutions-list', request, isMountedRef)

  return (
    <div className="md-container container">
      <div className="c-search-bar">
        <input
          className="--search"
          onChange={(e) => {
            setSearch(e.target.value)
          }}
          value={request.query.search || ''}
          placeholder="Search for an exercise"
        />
        <SolutionFilter
          setFilter={setFilter}
          value={request.query.filter || []}
          options={FILTERS}
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
        <div>
          <div className="results-title-bar">
            <h3>
              Showing {resolvedData.results.length}{' '}
              {pluralize('solutions', resolvedData.results.length)}
            </h3>
            <div className="c-select order">
              <select
                onChange={(e) => setSort(e.target.value)}
                value={request.query.sort}
              >
                <option value="oldest-first">Sort by Oldest First</option>
                <option value="newest-first">Sort by Newest First</option>
              </select>
            </div>
          </div>
          <div className="solutions">
            {resolvedData.results.map((solution) => {
              return <Solution {...solution} key={solution.id} />
            })}
          </div>
        </div>
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
