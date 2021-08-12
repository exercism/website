import React from 'react'
import { Notification as NotificationType } from '../../types'
import { Notification } from './Notification'

export const List = ({
  notifications,
}: {
  notifications: readonly NotificationType[]
}): JSX.Element => {
  return (
    <div>
      {notifications.map((notification) => (
        <Notification key={notification.url} {...notification} />
      ))}
    </div>
  )
}
