import React from 'react'
import { missingExerciseIconErrorHandler } from '@/components/common/imageErrorHandler'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type ExerciseIconProps = {
  iconUrl: string
  title?: string
  className?: string
}

export function ExerciseIcon({
  iconUrl,
  title,
  className,
}: ExerciseIconProps): JSX.Element {
  const { t } = useAppTranslation('components/common/ExerciseIcon.tsx')
  const classNames = ['c-icon c-exercise-icon']
  if (className !== undefined) {
    classNames.push(className)
  }

  return (
    <img
      className={classNames.join(' ')}
      src={iconUrl}
      alt={title ? t('iconForExercise', { title }) : ''}
      onError={missingExerciseIconErrorHandler}
    />
  )
}
