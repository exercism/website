// i18n-key-prefix: sizeTag
// i18n-namespace: components/contributing/tasks-list/task
import React from 'react'
import { TaskSize } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const SizeTag = ({ size }: { size?: TaskSize }): JSX.Element => {
  const { t } = useAppTranslation()

  switch (size) {
    case 'tiny':
      return <div className="size-tag">{t('sizeTag.xs')}</div>
    case 'small':
      return <div className="size-tag">{t('sizeTag.s')}</div>
    case 'medium':
      return <div className="size-tag">{t('sizeTag.m')}</div>
    case 'large':
      return <div className="size-tag">{t('sizeTag.l')}</div>
    case 'massive':
      return <div className="size-tag">{t('sizeTag.xl')}</div>
    default:
      return <div className="size-tag blank" />
  }
}
