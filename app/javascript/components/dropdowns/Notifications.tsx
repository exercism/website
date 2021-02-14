import React, { useEffect } from 'react'
import consumer from '../../utils/action-cable-consumer'
import { NotificationsIcon } from './notifications/NotificationsIcon'
import { UnrevealedBadgesContainer } from './notifications/UnrevealedBadgesContainer'
import { NotificationMenuItem } from './notifications/NotificationMenuItem'
import { Notification, UnrevealedBadgeList } from './notifications/types'
import { useDropdown, DropdownAttributes } from './useDropdown'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { useErrorHandler, ErrorBoundary } from '../ErrorBoundary'
import { Loading } from '../common/Loading'
import { QueryStatus } from 'react-query'

type APIResponse = {
  results: Notification[]
  unrevealedBadges: UnrevealedBadgeList
  meta: {
    unreadCount: number
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
      <ul className="c-notifications-dropdown" {...listAttributes}>
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

export const Notifications = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { data, error, status, refetch } = useRequestQuery<APIResponse>(
    'notifications',
    { endpoint: endpoint, options: {} },
    isMountedRef
  )
  const dropdownLength = data
    ? data.results.length + (data.unrevealedBadges ? 1 : 0)
    : 0
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
  } = useDropdown(dropdownLength)

  useEffect(() => {
    const subscription = consumer.subscriptions.create(
      { channel: 'NotificationsChannel' },
      { received: refetch }
    )
    return () => subscription.unsubscribe()
  }, [refetch])

  return (
    <div>
      <NotificationsIcon
        count={data?.meta?.unreadCount || 0}
        aria-label="Open notifications"
        {...buttonAttributes}
      />
      <div {...panelAttributes}>
        <DropdownContent
          data={data}
          status={status}
          error={error}
          itemAttributes={itemAttributes}
          listAttributes={listAttributes}
        />
      </div>
    </div>
  )
}
