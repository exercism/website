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
  selected: readonly string[]
  onSelect: (uuid: string) => void
  disabled: boolean
}): JSX.Element => {
  const handleChange = useCallback(
    (notification: NotificationType) => {
      return () => onSelect(notification.uuid)
    },
    [onSelect]
  )

  if (notifications.length === 0) {
    return <EmptyList />
  }

  return (
    <div className="notifications">
      {notifications.map((notification) => (
        <React.Fragment key={notification.uuid}>
          <label className="c-checkbox-wrapper">
            <input
              disabled={disabled}
              type="checkbox"
              checked={selected.includes(notification.uuid)}
              onChange={handleChange(notification)}
            />
            <div className="row">
              <div className="c-checkbox">
                <GraphicalIcon icon="checkmark" />
              </div>
            </div>
            <Notification {...notification} />
          </label>
        </React.Fragment>
      ))}
    </div>
  )
}
