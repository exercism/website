import React from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { PaginatedResult, Notification } from '../types'
import { ResultsZone } from '../ResultsZone'
import { List } from './notifications-list/List'
import { useList } from '../../hooks/use-list'
import { Pagination } from '../common'
import { useHistory, removeEmpty } from '../../hooks/use-history'

const DEFAULT_ERROR = new Error('Unable to load notifications')

export const NotificationsList = ({
  request: initialRequest,
}: {
  request: Request
}): JSX.Element => {
  const { request, setPage } = useList(initialRequest)
  const cacheKey = ['notifications-list', removeEmpty(request.query)]

  const {
    status,
    resolvedData,
    latestData,
    error,
    isFetching,
  } = usePaginatedRequestQuery<
    PaginatedResult<readonly Notification[]>,
    Error | Response
  >(cacheKey, request)

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          error={error}
          status={status}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <List notifications={resolvedData.results} />
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
  )
}
