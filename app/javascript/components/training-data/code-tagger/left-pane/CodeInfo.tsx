// i18n-key-prefix: leftPane.codeInfo
// i18n-namespace: components/training-data/code-tagger
import React from 'react'
import { TrackIcon, Avatar } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default function CodeInfo({
  track,
  exercise,
}: {
  track: any
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
            {t('leftPane.codeInfo.youAreAssigningTags')}
          </div>
          <div className="handle">
            {exercise.title} {t('leftPane.codeInfo.in')} {track.title}
          </div>
        </div>
      </div>
    </>
  )
}
