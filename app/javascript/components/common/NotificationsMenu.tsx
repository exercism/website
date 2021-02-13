import React from 'react'
import { UnrevealedBadgesContainer } from './notifications-menu/UnrevealedBadgesContainer'
import { NotificationsContainer } from './notifications-menu/NotificationsContainer'

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

export const NotificationsMenu = ({
  notifications,
  unrevealedBadges,
}: {
  notifications: Notification[]
  unrevealedBadges?: UnrevealedBadgeList
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
