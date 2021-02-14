import React from 'react'
import { UnrevealedBadgesContainer } from './notifications-menu/UnrevealedBadgesContainer'
import { NotificationsContainer } from './notifications-menu/NotificationsContainer'
import { useRequestQuery } from '../../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { Loading } from '../../common/Loading'
import { useErrorHandler, ErrorBoundary } from '../../ErrorBoundary'

type BadgeRarity = 'common' | 'rare' | 'ultimate' | 'legendary'

export type UnrevealedBadgeList = {
  badges: UnrevealedBadge[]
  links: {
    badges: string
  }
}

export type UnrevealedBadge = {
  rarity: BadgeRarity
}

type NotificationImageType = 'icon' | 'avatar'

export type Notification = {
  url: string
  imageType: NotificationImageType
  imageUrl: string
  text: string
  createdAt: string
  isRead: boolean
}

type APIResponse = {
  results: Notification[]
  unrevealedBadges: UnrevealedBadgeList
}

const Content = ({
  unrevealedBadges,
  notifications,
}: {
  unrevealedBadges: UnrevealedBadgeList
  notifications: Notification[]
}) => {
  return (
    <React.Fragment>
      {unrevealedBadges ? (
        <UnrevealedBadgesContainer
          badges={unrevealedBadges.badges}
          url={unrevealedBadges.links.badges}
        />
      ) : null}
      <NotificationsContainer notifications={notifications} />
    </React.Fragment>
  )
}

const DEFAULT_ERROR = new Error('Unable to load notifications')

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

export const NotificationsMenu = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()

  const { data, error, status } = useRequestQuery<APIResponse>(
    'notifications',
    { endpoint: endpoint, options: {} },
    isMountedRef
  )

  return (
    <div className="c-notifications-dropdown">
      {data ? (
        <Content
          unrevealedBadges={data.unrevealedBadges}
          notifications={data.results}
        />
      ) : null}
      {status === 'loading' ? <Loading /> : null}
      <ErrorBoundary FallbackComponent={ErrorFallback}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </div>
  )
}
