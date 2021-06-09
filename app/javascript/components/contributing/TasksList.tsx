import React from 'react'
import { GraphicalIcon, Pagination } from '../common'
import { Task } from './tasks-list/Task'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { Task as TaskProps, PaginatedResult } from '../types'
import { ResultsZone } from '../ResultsZone'
import { FetchingBoundary } from '../FetchingBoundary'
import { useList } from '../../hooks/use-list'

const DEFAULT_ERROR = new Error('Unable to pull tasks')

export const TasksList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage } = useList(initialRequest)
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<
    PaginatedResult<readonly TaskProps[]>,
    Error | Response
  >(
    ['contributing-tasks', request.endpoint, request.query],
    request,
    isMountedRef
  )

  return (
    <div className="lg-container container">
      <div className="c-search-bar">
        <div className="c-track-switcher --small">
          <button className="current-track">
            <GraphicalIcon icon="all-tracks" className="all" />
            <div className="track-title">All tracks</div>
            <GraphicalIcon icon="chevron-down" className="action-icon" />
          </button>
        </div>
        <div className="c-select">
          <select>
            <option>All actions</option>
          </select>
        </div>
        <div className="c-select">
          <select>
            <option>All types</option>
          </select>
        </div>
        <div className="c-select">
          <select>
            <option>All sizes</option>
          </select>
        </div>
        <div className="c-select">
          <select>
            <option>All knowledge</option>
          </select>
        </div>
        <div className="c-select">
          <select>
            <option>All modules</option>
          </select>
        </div>
      </div>
      <header className="main-header c-search-bar">
        <h2>
          <strong>Showing 7,195 tasks out of 7,195 possible tasks</strong>
        </h2>
        <button className="btn-m btn-link reset-btn">
          <GraphicalIcon icon="reset" />
          <span>Reset Filters</span>
        </button>
        <div className="c-select">
          <select>
            <option>Sort by most recent</option>
          </select>
        </div>
      </header>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <div className="tasks">
                {resolvedData.results.map((task) => (
                  <Task task={task} key={task.id} />
                ))}
                <Pagination
                  disabled={latestData === undefined}
                  current={request.query.page}
                  total={resolvedData.meta.totalPages}
                  setPage={setPage}
                />
              </div>
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
