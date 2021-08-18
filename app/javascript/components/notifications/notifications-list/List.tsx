import React, { useCallback } from 'react'
import { Notification as NotificationType } from '../../types'
import { Notification } from './Notification'
import { EmptyList } from './EmptyList'
import { GraphicalIcon } from '../../common'

export const List = ({
  notifications,
  selected,
  onSelect,
  disabled,
}: {
  notifications: readonly NotificationType[]
  selected: readonly NotificationType[]
  onSelect: (notification: NotificationType) => void
  disabled: boolean
}): JSX.Element => {
  const handleChange = useCallback(
    (notification: NotificationType) => {
      return () => onSelect(notification)
    },
    [onSelect]
  )

  if (notifications.length === 0) {
    return <EmptyList />
  }

  return (
    <div className="notifications">
      {notifications.map((notification) => (
        <div key={notification.uuid} className="notification-row">
          <label
            className={`c-checkbox-wrapper notification-cb-${notification.uuid}`}
          >
            <input
              disabled={disabled}
              type="checkbox"
              checked={selected.map((s) => s.uuid).includes(notification.uuid)}
              onChange={handleChange(notification)}
              id={`notification-cb-${notification.uuid}`}
            />
            <div className="row">
              <div className="c-checkbox">
                <GraphicalIcon icon="checkmark" />
              </div>
            </div>
          </label>
          <Notification {...notification} />
        </div>
      ))}
    </div>
  )
}
