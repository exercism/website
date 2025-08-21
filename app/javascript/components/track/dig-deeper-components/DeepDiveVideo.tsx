// i18n-key-prefix: deepDiveVideo
// i18n-namespace: components/track/dig-deeper-components
import React, { useContext } from 'react'
import { DigDeeperDataContext } from '../DigDeeper'
import YoutubePlayerWithMutation from '@/components/common/YoutubePlayerWithMutation'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function DeepDiveVideo() {
  const { exercise } = useContext(DigDeeperDataContext)
  const { t } = useAppTranslation('components/track/dig-deeper-components')

  if (!exercise || !exercise.deepDiveYoutubeId) {
    return null
  }

  return (
    <div className="mb-32 bg-backgroundColorA shadow-lg rounded-8 px-20 lg:px-32 py-20 lg:py-24">
      <h3 className="text-h3 mb-8">
        {t('deepDiveVideo.deepDiveInto', { exerciseTitle: exercise.title })}
      </h3>
      <p className="text-p-large mb-16">{exercise.deepDiveBlurb}</p>
      <div className="w-[100%]">
        <YoutubePlayerWithMutation
          id={exercise.deepDiveYoutubeId}
          markAsSeenEndpoint={exercise.deepDiveMarkAsSeenEndpoint}
        />
      </div>
    </div>
  )
}
