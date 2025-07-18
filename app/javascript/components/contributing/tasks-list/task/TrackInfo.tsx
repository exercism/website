// i18n-key-prefix: trackInfo
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { TrackIcon } from '../../../common'
import { Task } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const TrackInfo = ({ track }: Pick<Task, 'track'>): JSX.Element => {
  const { t } = useAppTranslation('components/contributing/tasks-list/task')
  return (
    <div className="track">
      <div className="for">{t('trackInfo.for')}</div>
      <TrackIcon iconUrl={track.iconUrl} title={track.title} />
      <div className="title">{track.title}</div>
    </div>
  )
}
