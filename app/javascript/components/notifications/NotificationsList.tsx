import React, { useState, useCallback, useMemo } from 'react'
import { useQueryCache } from 'react-query'
import { useList, useHistory, removeEmpty, useScrollToTop } from '@/hooks'
import { type Request, usePaginatedRequestQuery } from '@/hooks/request-query'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { Pagination, GraphicalIcon } from '@/components/common'
import {
  useNotificationMutation,
  MutationButton,
  List,
  MarkAllNotificationsAsReadModal,
} from './notifications-list'
import type { Notification } from '@/components/types'

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

type APIResponse = {
  results: readonly Notification[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    links: {
      all: string
    }
    unreadCount: number
  }
}

export default function NotificationsList({
  request: initialRequest,
  links,
}: {
  request: Request
  links: Links
}): JSX.Element {
  const queryCache = useQueryCache()
  const { request, setPage } = useList(initialRequest)
  const cacheKey = useMemo(
    () => ['notifications-list', removeEmpty(request.query)],
    [request.query]
  )
  const { status, resolvedData, latestData, error, isFetching } =
    usePaginatedRequestQuery<APIResponse, Error | Response>(cacheKey, request)

  const [selected, setSelected] = useState<Notification[]>([])

  const handleSelect = useCallback(
    (notification: Notification) => {
      if (selected.includes(notification)) {
        setSelected(selected.filter((s) => s !== notification))
      } else {
        setSelected([...selected, notification])
      }
    },
    [selected]
  )

  const markAsReadMutation = useNotificationMutation({
    endpoint: links.markAsRead,
    body: { uuids: selected.map((s) => s.uuid) },
  })
  const markAsUnreadMutation = useNotificationMutation({
    endpoint: links.markAsUnread,
    body: { uuids: selected.map((s) => s.uuid) },
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

  const [modalOpen, setModalOpen] = useState(false)
  const handleModalOpen = useCallback(() => {
    setModalOpen(true)
  }, [])
  const handleModalClose = useCallback(() => {
    setModalOpen(false)
  }, [])

  const handleMutation = useCallback(
    (mutation) => {
      return () => {
        mutation.mutation(
          { uuids: selected.map((s) => s.uuid) },
          {
            onSuccess: () => {
              setSelected([])
              queryCache.invalidateQueries(cacheKey)
            },
          }
        )
      }
    },
    [cacheKey, selected, queryCache]
  )

  const disabled = isFetching || mutations.some((m) => m.status === 'loading')

  const scrollToTopRef = useScrollToTop(request.query.page)

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <>
      <ResultsZone isFetching={disabled}>
        <header className="notifications-header" ref={scrollToTopRef}>
          <h1 className="text-h1">Notifications</h1>
          <div className="actions">
            <MutationButton
              mutation={markAsReadMutation}
              onClick={handleMutation(markAsReadMutation)}
              disabled={
                selected.length === 0 ||
                disabled ||
                selected.every((s) => s.isRead)
              }
              defaultError={MARK_AS_READ_DEFAULT_ERROR}
            >
              Mark as read
            </MutationButton>
            <MutationButton
              mutation={markAsUnreadMutation}
              onClick={handleMutation(markAsUnreadMutation)}
              disabled={
                selected.length === 0 ||
                disabled ||
                selected.every((s) => !s.isRead)
              }
              defaultError={MARK_AS_UNREAD_DEFAULT_ERROR}
            >
              Mark as unread
            </MutationButton>
            <button
              type="button"
              onClick={handleModalOpen}
              disabled={disabled || resolvedData?.meta.unreadCount === 0}
              className="btn-s btn-enhanced"
            >
              <GraphicalIcon icon="double-checkmark" />
              <span>Mark all as read</span>
            </button>
          </div>
        </header>
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
                current={request.query.page || 1}
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
        onSubmit={handleMutation(markAllAsReadMutation)}
        mutation={markAllAsReadMutation}
      />
    </>
  )
}
