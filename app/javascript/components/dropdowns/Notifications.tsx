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
            <span>
              {t('notifications.seeAllYourNotifications', {
                icon: <GraphicalIcon icon="arrow-right" />,
              })}
            </span>
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
}: {
  endpoint: string
}): JSX.Element {
  const queryClient = useQueryClient()
  const {
    data: resolvedData,
    error,
    status,
  } = usePaginatedRequestQuery<APIResponse, unknown>(
    [NOTIFICATIONS_CACHE_KEY],
    {
      endpoint: endpoint,
      query: { per_page: MAX_NOTIFICATIONS },
      options: {
        staleTime: 30 * 1000,
        refetchOnMount: true,
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

  useEffect(() => {
    if (!connectionRef.current) {
      connectionRef.current = new NotificationsChannel((message) => {
        if (!message) return

        if (message.type === 'notifications.changed' && listAttributes.hidden) {
          queryClient.invalidateQueries({ queryKey: [NOTIFICATIONS_CACHE_KEY] })
        }
      })
    }

    if (!listAttributes.hidden) {
      queryClient.refetchQueries({ queryKey: [NOTIFICATIONS_CACHE_KEY] })
    }

    return () => {
      connectionRef.current?.disconnect()
      connectionRef.current = null
    }
  }, [listAttributes.hidden, queryClient])

  return (
    <React.Fragment>
      <NotificationsIcon
        count={resolvedData?.meta?.unreadCount || 0}
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
