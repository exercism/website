// i18n-key-prefix: trackInfo
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { TrackIcon } from '../../../common'
import { Task } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const TrackInfo = ({ track }: Pick<Task, 'track'>): JSX.Element => {
  useAppTranslation()
  return (
    <div className="track">
      <Trans
        i18nKey="trackInfo.for"
        values={{ trackTitle: track.title }}
        components={[
          <div className="for" />,
          <div className="title" />,
          <TrackIcon iconUrl={track.iconUrl} title={track.title} />,
        ]}
      />
    </div>
  )
}
