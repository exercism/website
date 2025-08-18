// i18n-key-prefix: newTag
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { GraphicalIcon } from '../../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const NewTag = (): JSX.Element => {
  const { t } = useAppTranslation('components/contributing/tasks-list/task')
  return (
    <div className="new">
      <GraphicalIcon icon="stars" />
      {t('newTag.new')}
    </div>
  )
}
