import React, { useState, useCallback, useMemo } from 'react'
import { Request, usePaginatedRequestQuery } from '../../hooks/request-query'
import { FetchingBoundary } from '../FetchingBoundary'
import { PaginatedResult, Notification } from '../types'
import { ResultsZone } from '../ResultsZone'
import { List } from './notifications-list/List'
import { useList } from '../../hooks/use-list'
import { Pagination } from '../common'
import { useHistory, removeEmpty } from '../../hooks/use-history'
import { queryCache } from 'react-query'
import { useNotificationMutation } from './notifications-list/useNotificationMutation'
import { MutationButton } from './notifications-list/MutationButton'

const DEFAULT_ERROR = new Error('Unable to load notifications')
const MARK_AS_READ_DEFAULT_ERROR = new Error(
  'Unable to mark notifications as read'
)

export type Links = {
  markAsRead: string
}

export const NotificationsList = ({
  request: initialRequest,
  links,
}: {
  request: Request
  links: Links
}): JSX.Element => {
  const { request, setPage } = useList(initialRequest)
  const cacheKey = useMemo(
    () => ['notifications-list', removeEmpty(request.query)],
    [request.query]
  )
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

  const [selected, setSelected] = useState<string[]>([])

  const handleSelect = useCallback(
    (uuid: string) => {
      if (selected.includes(uuid)) {
        setSelected(selected.filter((s) => s !== uuid))
      } else {
        setSelected([...selected, uuid])
      }
    },
    [selected]
  )

  const markAsReadMutation = useNotificationMutation(links.markAsRead)

  const handleMutation = useCallback(
    (mutation) => {
      return () => {
        mutation.mutation(
          { uuids: selected },
          {
            onSuccess: () => {
              setSelected([])
              queryCache.invalidateQueries(cacheKey)
            },
          }
        )
      }
    },
    [cacheKey, selected]
  )

  const disabled = isFetching || markAsReadMutation.status === 'loading'

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <div>
      <ResultsZone isFetching={disabled}>
        {selected.length !== 0 ? (
          <div className="actions">
            <MutationButton
              mutation={markAsReadMutation}
              onClick={handleMutation(markAsReadMutation)}
              disabled={isFetching}
              defaultError={MARK_AS_READ_DEFAULT_ERROR}
            />
          </div>
        ) : null}
        <FetchingBoundary
          error={error}
          status={status}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <List
                notifications={resolvedData.results}
                selected={selected}
                onSelect={handleSelect}
                disabled={disabled}
              />
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
