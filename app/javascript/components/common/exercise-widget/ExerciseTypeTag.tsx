// i18n-key-prefix: exerciseTypeTag
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { GraphicalIcon } from '../../common'
import { Size, ExerciseType } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ExerciseTypeTag = ({
  type,
  size,
}: {
  type: ExerciseType
  size?: Size
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/exercise-widget')
  const sizeClassName = size ? `--${size}` : ''

  switch (type) {
    case 'concept':
      return (
        <div className={`c-exercise-type-tag --concept ${sizeClassName}`}>
          <GraphicalIcon icon="concept-exercise" />{' '}
          {t('exerciseTypeTag.learningExercise')}
        </div>
      )
    case 'tutorial':
      return (
        <div className={`c-exercise-type-tag --tutorial ${sizeClassName}`}>
          {t('exerciseTypeTag.tutorialExercise')}
        </div>
      )
    default:
      return <></>
  }
}
