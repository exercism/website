import React from 'react'
import { SizeTag } from '../../contributing/tasks-list/task/SizeTag'
import { TaskSize } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SizeInfo = ({ size }: { size: TaskSize }): JSX.Element => {
  return (
    <section>
      <div className="icon">
        <SizeTag size={size} />
      </div>
      <div className="details">
        <SizeDetails size={size} />
      </div>
    </section>
  )
}

const SizeDetails = ({ size }: { size: TaskSize }): JSX.Element => {
  const { t } = useAppTranslation('components/tooltips/task-tooltip')

  switch (size) {
    case 'tiny':
      return (
        <>
          <h3>{t('sizeInfo.tinyTask')}</h3>
          <p>{t('sizeInfo.completeInMinutes')}</p>
        </>
      )
    case 'small':
      return (
        <>
          <h3>{t('sizeInfo.smallTask')}</h3>
          <p>{t('sizeInfo.completeInHour')}</p>
        </>
      )
    case 'medium':
      return (
        <>
          <h3>{t('sizeInfo.mediumSizedTask')}</h3>
          <p>{t('sizeInfo.deepenKnowledge')}</p>
        </>
      )
    case 'large':
      return (
        <>
          <h3>{t('sizeInfo.largeTask')}</h3>
          <p>{t('sizeInfo.bigContribution')}</p>
        </>
      )
    case 'massive':
      return (
        <>
          <h3>{t('sizeInfo.project')}</h3>
          <p>{t('sizeInfo.daysToComplete')}</p>
        </>
      )
  }
}
