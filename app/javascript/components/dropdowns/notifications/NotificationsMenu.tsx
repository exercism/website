import React from 'react'
import { UnrevealedBadgesContainer } from './notifications-menu/UnrevealedBadgesContainer'
import { NotificationsContainer } from './notifications-menu/NotificationsContainer'
import { Notification, UnrevealedBadgeList } from './types'

export const NotificationsMenu = ({
  unrevealedBadges,
  notifications,
}: {
  unrevealedBadges: UnrevealedBadgeList
  notifications: Notification[]
}): JSX.Element => {
  return (
    <div className="c-notifications-dropdown">
      {unrevealedBadges ? (
        <UnrevealedBadgesContainer
          badges={unrevealedBadges.badges}
          url={unrevealedBadges.links.badges}
        />
      ) : null}
      <NotificationsContainer notifications={notifications} />
    </div>
  )
}
