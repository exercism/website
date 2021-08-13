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
import { MarkAllNotificationsAsReadModal } from './notifications-list/MarkAllNotificationsAsReadModal'

const DEFAULT_ERROR = new Error('Unable to load notifications')
const MARK_AS_READ_DEFAULT_ERROR = new Error(
  'Unable to mark notifications as read'
)
const MARK_AS_UNREAD_DEFAULT_ERROR = new Error(
  'Unable to mark notifications as unread'
)

export type Links = {
  markAsRead: string
  markAllAsRead: string
  markAsUnread: string
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

  const markAsReadMutation = useNotificationMutation({
    endpoint: links.markAsRead,
    body: { uuids: selected },
  })
  const markAsUnreadMutation = useNotificationMutation({
    endpoint: links.markAsUnread,
    body: { uuids: selected },
  })
  const markAllAsReadMutation = useNotificationMutation({
    endpoint: links.markAllAsRead,
    body: null,
  })
  const mutations = [
    markAsReadMutation,
    markAsUnreadMutation,
    markAllAsReadMutation,
  ]

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

  const disabled = isFetching || mutations.some((m) => m.status === 'loading')

  useHistory({ pushOn: removeEmpty(request.query) })

  const [modalOpen, setModalOpen] = useState(false)
  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])
  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  return (
    <div>
      <ResultsZone isFetching={disabled}>
        <div className="actions">
          <MutationButton
            mutation={markAsReadMutation}
            onClick={handleMutation(markAsReadMutation)}
            disabled={selected.length === 0 || disabled}
            defaultError={MARK_AS_READ_DEFAULT_ERROR}
          >
            Mark as read
          </MutationButton>
          <MutationButton
            mutation={markAsUnreadMutation}
            onClick={handleMutation(markAsUnreadMutation)}
            disabled={selected.length === 0 || disabled}
            defaultError={MARK_AS_UNREAD_DEFAULT_ERROR}
          >
            Mark as unread
          </MutationButton>
          <button type="button" onClick={handleModalOpen} disabled={disabled}>
            Mark all as read
          </button>
        </div>
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
      <MarkAllNotificationsAsReadModal
        open={modalOpen}
        onClose={handleModalClose}
        mutation={markAllAsReadMutation}
      />
    </div>
  )
}
