export type Notification = {
  url: string
  imageType: NotificationImageType
  imageUrl: string
  text: string
  createdAt: string
  isRead: boolean
}

type NotificationImageType = 'icon' | 'avatar'
