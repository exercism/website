import React from 'react'
import { Notification } from '../types'
import { fromNow } from '../../../../utils/time'
import { GraphicalIcon } from '../../../common'

export const NotificationsContainer = ({
  notifications,
}: {
  notifications: Notification[]
}): JSX.Element => {
  return (
    <React.Fragment>
      {notifications.map((notification, i) => (
        <NotificationMenuItem key={i} {...notification} />
      ))}
    </React.Fragment>
  )
}

const NotificationImage = ({
  imageType,
  imageUrl,
}: Pick<Notification, 'imageType' | 'imageUrl'>) => {
  switch (imageType) {
    case 'avatar':
      return (
        <div
          className="c-rounded-bg-img"
          style={{ backgroundImage: `url(${imageUrl})` }}
        />
      )
    default:
      return <img role="presentation" src={imageUrl} className="icon" />
  }
}

const NotificationStatus = ({ isRead }: Pick<Notification, 'isRead'>) => {
  const className = isRead ? 'read' : 'unread'

  return <div className={className} />
}

const NotificationContent = ({
  text,
  createdAt,
}: Pick<Notification, 'text' | 'createdAt'>) => {
  return (
    <div className="content">
      <div className="text" dangerouslySetInnerHTML={{ __html: text }} />
      <div className="created-at">{fromNow(createdAt)}</div>
    </div>
  )
}

const NotificationMenuItem = ({
  url,
  imageType,
  imageUrl,
  text,
  createdAt,
  isRead,
}: Notification) => {
  return (
    <a href={url} className="notification">
      <NotificationImage imageType={imageType} imageUrl={imageUrl} />
      <NotificationContent text={text} createdAt={createdAt} />
      <NotificationStatus isRead={isRead} />
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
