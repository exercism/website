import React from 'react'
import { NotificationsIcon } from './notifications/NotificationsIcon'
import { NotificationsMenu } from './notifications/NotificationsMenu'
import { useDropdown } from './useDropdown'

export const Notifications = ({
  endpoint,
}: {
  endpoint: string
}): JSX.Element => {
  const { buttonAttributes, panelAttributes, listAttributes } = useDropdown(0)

  return (
    <div>
      <NotificationsIcon
        count={0}
        aria-label="Open notifications"
        {...buttonAttributes}
      />
      <div {...panelAttributes}>
        <ul {...listAttributes}>
          <NotificationsMenu endpoint={endpoint} />
        </ul>
      </div>
    </div>
  )
}
