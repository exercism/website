import React, { useEffect } from 'react'
import consumer from '../../utils/action-cable-consumer'
import { NotificationsIcon } from './notifications/NotificationsIcon'
import { NotificationsMenu } from './notifications/NotificationsMenu'
import { Notification, UnrevealedBadgeList } from './notifications/types'
import { useDropdown } from './useDropdown'
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
  id,
  role,
  hidden,
}: {
  data: APIResponse | undefined
  status: QueryStatus
  error: unknown
  id: string
  role: string
  hidden: boolean
}) => {
  if (data) {
    return (
      <ul id={id} role={role} hidden={hidden}>
        {data ? (
          <NotificationsMenu
            unrevealedBadges={data.unrevealedBadges}
            notifications={data.results}
          />
        ) : null}
      </ul>
    )
  } else {
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
  const { buttonAttributes, panelAttributes, listAttributes } = useDropdown(0)

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
          {...listAttributes}
        />
      </div>
    </div>
  )
}
