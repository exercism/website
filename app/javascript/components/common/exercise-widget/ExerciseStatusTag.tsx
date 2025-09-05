// i18n-key-prefix: exerciseStatusTag
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { Exercise, Size } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ExerciseStatusTag = ({
  exercise,
  size,
}: {
  exercise: Exercise
  size?: Size
}): JSX.Element => {
  const { t } = useAppTranslation()
  if (exercise.isExternal) {
    return <></>
  }

  const sizeClassName = size ? `--${size}` : ''

  if (exercise.isRecommended) {
    return (
      <div className={`c-exercise-status-tag --recommended ${sizeClassName}`}>
        {t('exerciseStatusTag.recommended')}
      </div>
    )
  } else if (exercise.isUnlocked) {
    return (
      <div className={`c-exercise-status-tag --available ${sizeClassName}`}>
        {t('exerciseStatusTag.available')}
      </div>
    )
  } else {
    return (
      <div className={`c-exercise-status-tag --locked ${sizeClassName}`}>
        {t('exerciseStatusTag.locked')}
      </div>
    )
  }
}
