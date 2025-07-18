// i18n-key-prefix: solutionStatusTag
// i18n-namespace: components/common/exercise-widget
import React from 'react'
import { SolutionStatus, Size } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SolutionStatusTag = ({
  status,
  size,
}: {
  status: SolutionStatus
  size: Size
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/exercise-widget')
  const sizeClassName = size ? `--${size}` : ''

  switch (status) {
    case 'published':
      return (
        <div className={`c-exercise-status-tag --published ${sizeClassName}`}>
          {t('solutionStatusTag.published')}
        </div>
      )
    case 'completed':
      return (
        <div className={`c-exercise-status-tag --completed ${sizeClassName}`}>
          {t('solutionStatusTag.completed')}
        </div>
      )
    case 'started':
    case 'iterated':
      return (
        <div className={`c-exercise-status-tag --in-progress ${sizeClassName}`}>
          {t('solutionStatusTag.inProgress')}
        </div>
      )
  }
}
