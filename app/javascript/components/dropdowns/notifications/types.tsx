export type UnrevealedBadgeList = {
  badges: UnrevealedBadge[]
  links: {
    badges: string
  }
}

export type UnrevealedBadge = {
  rarity: BadgeRarity
}

type BadgeRarity = 'common' | 'rare' | 'ultimate' | 'legendary'

export type Notification = {
  url: string
  imageType: NotificationImageType
  imageUrl: string
  text: string
  createdAt: string
  isRead: boolean
}

type NotificationImageType = 'icon' | 'avatar'
