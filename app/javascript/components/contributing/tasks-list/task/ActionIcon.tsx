// i18n-key-prefix: actionIcon
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { GraphicalIcon, Icon } from '../../../common'
import { TaskAction } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ActionIcon = ({
  action,
}: {
  action?: TaskAction
}): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <div className="action-icon">
      {action ? (
        <Icon
          icon={`task-action-${action}`}
          alt={t('actionIcon.action', { action })}
        />
      ) : (
        <GraphicalIcon icon={`task-action`} />
      )}
    </div>
  )
}
