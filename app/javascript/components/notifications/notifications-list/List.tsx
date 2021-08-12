import React from 'react'
import { Notification as NotificationType } from '../../types'
import { Notification } from './Notification'
import { EmptyList } from './EmptyList'

export const List = ({
  notifications,
}: {
  notifications: readonly NotificationType[]
}): JSX.Element => {
  if (notifications.length === 0) {
    return <EmptyList />
  }

  return (
    <div>
      {notifications.map((notification) => (
        <Notification key={notification.url} {...notification} />
      ))}
    </div>
  )
}
