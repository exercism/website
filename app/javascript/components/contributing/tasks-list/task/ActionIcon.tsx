import React from 'react'
import { GraphicalIcon, Icon } from '../../../common'
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
      ) : (
        <GraphicalIcon icon={`task-action`} />
      )}
    </div>
  )
}
