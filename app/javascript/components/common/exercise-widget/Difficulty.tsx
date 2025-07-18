// i18n-key-prefix: difficulty
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { ExerciseDifficulty, Size } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Difficulty = ({
  difficulty,
  size,
}: {
  difficulty: ExerciseDifficulty
  size?: Size
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/exercise-widget')
  const sizeClassName = size ? `--${size}` : ''

  switch (difficulty) {
    case 'easy':
      return (
        <div className={`c-difficulty-tag --easy ${sizeClassName}`}>
          <div className="icon"></div>
          {t('difficulty.easy')}
        </div>
      )
    case 'medium':
      return (
        <div className={`c-difficulty-tag --medium ${sizeClassName}`}>
          <div className="icon"></div>Medium
        </div>
      )
    case 'hard':
      return (
        <div className={`c-difficulty-tag --hard ${sizeClassName}`}>
          <div className="icon"></div>
          {t('difficulty.hard')}
        </div>
      )
  }
}
