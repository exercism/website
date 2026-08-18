import React, { useEffect, useRef, useState } from 'react'
import consumer from '../../utils/action-cable-consumer'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { NotificationsIcon } from './notifications/NotificationsIcon'
import { Notification } from '../notifications/notifications-list/Notification'
import { Notification as NotificationType } from '../types'
import { useNotificationDropdown } from './notifications/useNotificationDropdown'
import { DropdownAttributes } from './useDropdown'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useErrorHandler, ErrorBoundary } from '../ErrorBoundary'
import { Loading } from '../common/Loading'
import { QueryStatus, useQueryClient } from '@tanstack/react-query'
import { NotificationsChannel } from '@/channels/notificationsChannel'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type APIResponse = {
  results: NotificationType[]
  meta: {
    total: number
    unreadCount: number
    links: {
      all: string
    }
  }
}

const DEFAULT_ERROR = new Error('Unable to load notifications')

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

const DropdownContent = ({
  data,
  status,
  error,
  listAttributes,
  itemAttributes,
}: {
  data: APIResponse | undefined
  status: QueryStatus
  error: unknown
} & Pick<DropdownAttributes, 'listAttributes' | 'itemAttributes'>) => {
  const { t } = useAppTranslation('components/dropdowns')
  if (data) {
    return (
      <ul {...listAttributes}>
        {data.results.map((notification, i) => {
          return (
            <li {...itemAttributes(i)} key={i}>
              <Notification {...notification} />
            </li>
          )
        })}
        <li {...itemAttributes(data.results.length)}>
          <a href={data.meta.links.all} className="c-prominent-link">
            <span>{t('notifications.seeAllYourNotifications')}</span>
            <GraphicalIcon icon="arrow-right" />
          </a>
        </li>
      </ul>
    )
  } else {
    const { id, hidden } = listAttributes

    return (
      <div id={id} hidden={hidden}>
        {status === 'pending' ? <Loading /> : null}
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <ErrorMessage error={error} />
        </ErrorBoundary>
      </div>
    )
  }
}

const MAX_NOTIFICATIONS = 5
export const NOTIFICATIONS_CACHE_KEY = 'notifications'

export default function Notifications({
  endpoint,
  defaultUnreadCount,
}: {
  endpoint: string
  defaultUnreadCount: number
}): JSX.Element {
  const queryClient = useQueryClient()
  const [unreadCount, setUnreadCount] = useState(defaultUnreadCount)
  // The badge is seeded from defaultUnreadCount (rendered server-side), so we
  // don't need to fetch the notification list until the user actually opens
  // the dropdown.
  const [hasOpenedOnce, setHasOpenedOnce] = useState(false)
  const {
    data: resolvedData,
    error,
    status,
    refetch,
  } = usePaginatedRequestQuery<APIResponse, unknown>(
    [NOTIFICATIONS_CACHE_KEY],
    {
      endpoint: endpoint,
      query: { per_page: MAX_NOTIFICATIONS },
      options: {
        staleTime: 30 * 1000,
        enabled: hasOpenedOnce,
      },
    }
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useNotificationDropdown(resolvedData)

  const connectionRef = useRef<NotificationsChannel | null>(null)
  const hiddenRef = useRef(listAttributes.hidden)
  const refetchRef = useRef(refetch)
  hiddenRef.current = listAttributes.hidden
  refetchRef.current = refetch

  useEffect(() => {
    if (!resolvedData) {
      return
    }

    setUnreadCount(resolvedData.meta.unreadCount)
  }, [resolvedData])

  useEffect(() => {
    if (!connectionRef.current) {
      connectionRef.current = new NotificationsChannel((message) => {
        if (!message) return

        // Refetch (which also refreshes the badge count) whenever the
        // dropdown is closed, even if it's never been opened yet. `refetch`
        // works regardless of the query's `enabled` state. While the
        // dropdown is open we leave the visible list alone so it doesn't
        // shift under the user.
        if (message.type === 'notifications.changed' && hiddenRef.current) {
          refetchRef.current()
        }
      })
    }

    return () => {
      connectionRef.current?.disconnect()
      connectionRef.current = null
    }
  }, [])

  useEffect(() => {
    if (listAttributes.hidden) {
      return
    }

    if (!hasOpenedOnce) {
      setHasOpenedOnce(true)
      return
    }

    queryClient.refetchQueries({ queryKey: [NOTIFICATIONS_CACHE_KEY] })
  }, [listAttributes.hidden, hasOpenedOnce, queryClient])

  return (
    <React.Fragment>
      <NotificationsIcon
        count={unreadCount}
        aria-label="Open notifications"
        {...buttonAttributes}
      />
      {open ? (
        <div className="c-notifications-dropdown" {...panelAttributes}>
          <DropdownContent
            data={resolvedData}
            status={status}
            error={error}
            itemAttributes={itemAttributes}
            listAttributes={listAttributes}
          />
        </div>
      ) : null}
    </React.Fragment>
  )
}
