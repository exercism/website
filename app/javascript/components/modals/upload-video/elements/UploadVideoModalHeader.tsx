import React from 'react'
import { ExerciseTrackIndicator } from './ExerciseTrackIndicator'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function UploadVideoModalHeader({
  videoRetrieved = false,
}: {
  videoRetrieved?: boolean
}): JSX.Element {
  const { t } = useAppTranslation('components/modals/upload-video/elements')

  return (
    <>
      <h2 className="text-h2 mb-8">
        {t('uploadVideoModalHeader.submitACommunityWorkthrough')}
      </h2>
      <p className="text-prose mb-24">
        <Trans
          i18nKey="uploadVideoModalHeader.producedAVideoOfWorkingThroughThisExerciseYourselfWantToShareItWithTheExercismCommunity"
          components={[<strong className="font-medium text" />]}
        />
      </p>
      <ExerciseTrackIndicator videoRetrieved={videoRetrieved} />
    </>
  )
}
