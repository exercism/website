// i18n-key-prefix: representationInfo
// i18n-namespace: components/mentoring/representation/left-pane
import React from 'react'
import { TrackIcon, Avatar } from '../../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default function RepresentationInfo({
  track,
  exercise,
}: {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  track: any
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  exercise: any
}): JSX.Element {
  const { t } = useAppTranslation()

  return (
    <>
      <TrackIcon
        title={track.title}
        className={'!w-[32px] !h-[32px]'}
        iconUrl={track.iconUrl}
      />
      <div className="student">
        <Avatar src={exercise.iconUrl} />
        <div className="info">
          <div className="exercise">
            {t('representationInfo.feedbackOnSolution')}
          </div>
          <div className="handle">
            {t('leftPane.exerciseInTrack', {
              exerciseTitle: exercise.title,
              trackTitle: track.title,
            })}
          </div>
        </div>
      </div>
    </>
  )
}
