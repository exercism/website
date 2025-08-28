// i18n-key-prefix: trackInfo
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { TrackIcon } from '../../../common'
import { Task } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const TrackInfo = ({ track }: Pick<Task, 'track'>): JSX.Element => {
  useAppTranslation('components/contributing/tasks-list/task')
  return (
    <div className="track">
      <Trans
        ns="components/contributing/tasks-list/task"
        i18nKey="trackInfo.for"
        values={{ trackTitle: track.title }}
        components={[
          <div className="for" />,
          <TrackIcon iconUrl={track.iconUrl} title={track.title} />,
          <div className="title" />,
        ]}
      />
    </div>
  )
}
