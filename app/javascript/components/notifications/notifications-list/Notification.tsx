import React from 'react'
import { Notification as NotificationType } from '../../types'
import { fromNow } from '../../../utils/time'
import { GraphicalIcon } from '../../common'

const NotificationImage = ({
  imageType,
  imageUrl,
  iconFilter,
}: Pick<NotificationType, 'imageType' | 'imageUrl' | 'iconFilter'>) => {
  switch (imageType) {
    case 'avatar':
      return (
        <div
          className="c-avatar"
          style={{ backgroundImage: `url(${imageUrl})` }}
        />
      )
    default:
      return (
        <img alt="" src={imageUrl} className={`icon filter-${iconFilter}`} />
      )
  }
}

const NotificationStatus = ({ isRead }: Pick<NotificationType, 'isRead'>) => {
  const className = isRead ? 'read' : 'unread'

  return <div className={className} />
}

const NotificationContent = ({
  text,
  createdAt,
}: Pick<NotificationType, 'text' | 'createdAt'>) => {
  return (
    <div className="content">
      <div className="text" dangerouslySetInnerHTML={{ __html: text }} />
      <div className="created-at">{fromNow(createdAt)}</div>
    </div>
  )
}

export const Notification = ({
  url,
  imageType,
  imageUrl,
  text,
  createdAt,
  isRead,
  iconFilter,
}: NotificationType): JSX.Element => {
  return (
    <a href={url} className={`notification ${isRead ? '--read' : '--unread'}`}>
      <NotificationImage
        iconFilter={iconFilter}
        imageType={imageType}
        imageUrl={imageUrl}
      />
      <NotificationContent text={text} createdAt={createdAt} />
      <NotificationStatus isRead={isRead} />
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
