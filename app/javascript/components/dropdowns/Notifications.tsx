import React, { useEffect } from 'react'
import consumer from '../../utils/action-cable-consumer'
import { GraphicalIcon } from '../common/GraphicalIcon'
import { NotificationsIcon } from './notifications/NotificationsIcon'
import { UnrevealedBadgesContainer } from './notifications/UnrevealedBadgesContainer'
import { NotificationMenuItem } from './notifications/NotificationMenuItem'
import { Notification, UnrevealedBadgeList } from './notifications/types'
import { useNotificationDropdown } from './notifications/useNotificationDropdown'
import { DropdownAttributes } from './useDropdown'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useErrorHandler, ErrorBoundary } from '../ErrorBoundary'
import { Loading } from '../common/Loading'
import { QueryStatus } from 'react-query'

export type APIResponse = {
  results: Notification[]
  unrevealedBadges: UnrevealedBadgeList
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
  if (data) {
    const startIndex = data.unrevealedBadges ? 1 : 0

    return (
      <ul {...listAttributes}>
        {data.unrevealedBadges ? (
          <li {...itemAttributes(0)}>
            <UnrevealedBadgesContainer
              badges={data.unrevealedBadges.badges}
              url={data.unrevealedBadges.links.badges}
            />
          </li>
        ) : null}
        {data.results.map((notification, i) => {
          return (
            <li {...itemAttributes(startIndex + i)} key={i}>
              <NotificationMenuItem {...notification} />
            </li>
          )
        })}
        <li {...itemAttributes(startIndex + data.results.length)}>
          <a href={data.meta.links.all} className="c-prominent-link">
            <span>See all your notifications</span>
            <GraphicalIcon icon="arrow-right" />
          </a>
        </li>
      </ul>
    )
  } else {
    const { id, hidden } = listAttributes

    return (
      <div id={id} hidden={hidden}>
        {status === 'loading' ? <Loading /> : null}
        <ErrorBoundary FallbackComponent={ErrorFallback}>
          <ErrorMessage error={error} />
        </ErrorBoundary>
      </div>
    )
  }
}

const MAX_NOTIFICATIONS = 5

export const Notifications = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { data, error, status, refetch } = useRequestQuery<APIResponse>(
    'notifications',
    { endpoint: endpoint, query: { per: MAX_NOTIFICATIONS }, options: {} },
    isMountedRef
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
  } = useNotificationDropdown(data)

  useEffect(() => {
    const subscription = consumer.subscriptions.create(
      { channel: 'NotificationsChannel' },
      { received: refetch }
    )
    return () => subscription.unsubscribe()
  }, [refetch])

  return (
    <React.Fragment>
      <NotificationsIcon
        count={data?.meta?.unreadCount || 0}
        aria-label="Open notifications"
        {...buttonAttributes}
      />
      <div className="c-notifications-dropdown" {...panelAttributes}>
        <DropdownContent
          data={data}
          status={status}
          error={error}
          itemAttributes={itemAttributes}
          listAttributes={listAttributes}
        />
      </div>
    </React.Fragment>
  )
}
