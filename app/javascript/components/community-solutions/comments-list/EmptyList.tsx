import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const EmptyList = (): JSX.Element => {
  const { t } = useAppTranslation('components/community-solutions')
  return (
    <div className="flex flex-col lg:items-center lg:center">
      <h3 className="text-h5 text-textColor6 mb-2">
        {t('commentsList.emptyList.noComments')}
      </h3>
      <p className="text-p-base.text-textColor6">
        {t('commentsList.emptyList.beFirst')}
      </p>
    </div>
  )
}
