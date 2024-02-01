import React, { useState, useCallback, useMemo, useEffect } from 'react'
import { useQueryClient } from '@tanstack/react-query'
import { type Request, usePaginatedRequestQuery } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
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
import { scrollToTop } from '@/utils/scroll-to-top'

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
  const queryClient = useQueryClient()

  const [currentData, setCurrentData] = useState<APIResponse | undefined>()
  const { request, setPage } = useList(initialRequest)
  const cacheKey = useMemo(
    () => ['notifications-list', removeEmpty(request.query)],
    [request.query]
  )
  const {
    status,
    data: resolvedData,
    error,
    isFetching,
  } = usePaginatedRequestQuery<APIResponse, Error | Response>(cacheKey, request)

  useEffect(() => {
    if (!isFetching) setCurrentData(resolvedData)
  }, [resolvedData, isFetching])

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
              queryClient.invalidateQueries(cacheKey)
            },
          }
        )
      }
    },
    [cacheKey, selected, queryClient]
  )

  const disabled = isFetching || mutations.some((m) => m.status === 'loading')

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <>
      <ResultsZone isFetching={disabled}>
        <header className="notifications-header">
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
              disabled={disabled || currentData?.meta.unreadCount === 0}
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
          {currentData ? (
            <React.Fragment>
              <List
                notifications={currentData.results}
                selected={selected}
                onSelect={handleSelect}
                disabled={disabled}
              />
              <Pagination
                disabled={currentData === undefined}
                current={request.query.page || 1}
                total={currentData.meta.totalPages}
                setPage={(p) => {
                  setPage(p)
                  scrollToTop()
                }}
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
