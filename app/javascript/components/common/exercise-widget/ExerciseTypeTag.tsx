// i18n-key-prefix: exerciseTypeTag
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { GraphicalIcon } from '../../common'
import { Size, ExerciseType } from '../../types'
import { useTranslation } from 'react-i18next'
const { t } = useTranslation('components/common/exercise-widget')

export const ExerciseTypeTag = ({
  type,
  size,
}: {
  type: ExerciseType
  size?: Size
}): JSX.Element => {
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
