import React from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { PaginatedResult, Notification } from '../types'
import { ResultsZone } from '../ResultsZone'
import { List } from './notifications-list/List'

const DEFAULT_ERROR = new Error('Unable to load notifications')

export const NotificationsList = ({
  request,
}: {
  request: Request
}): JSX.Element => {
  const { status, resolvedData, error, isFetching } = usePaginatedRequestQuery<
    PaginatedResult<readonly Notification[]>,
    Error | Response
  >('notifications-list', request)

  return (
    <div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          error={error}
          status={status}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? <List notifications={resolvedData.results} /> : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
