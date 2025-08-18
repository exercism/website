import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SelectedTracksMessage = ({
  numSelected,
}: {
  numSelected: number
}): JSX.Element => {
  const { t } = useAppTranslation('components/mentoring/track-selector')

  const classNames = ['selected', numSelected === 0 ? 'none' : ''].filter(
    Boolean
  )

  const message = t('selectedTracks', {
    count: numSelected,
  })

  return <div className={classNames.join(' ')}>{message}</div>
}
