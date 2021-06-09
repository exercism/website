import React from 'react'
import { Icon } from '../../../common'
import { TaskAction } from '../../../types'

export const ActionIcon = ({
  action,
}: {
  action?: TaskAction
}): JSX.Element => {
  return (
    <div className="action-icon">
      {action ? (
        <Icon icon={`task-action-${action}`} alt={`Action: ${action}`} />
      ) : null}
    </div>
  )
}
