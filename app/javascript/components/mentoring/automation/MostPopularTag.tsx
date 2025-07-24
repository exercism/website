import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function MostPopularTag(): JSX.Element {
  const { t } = useAppTranslation('automation-batch')
  return (
    <div className="flex items-center justify-center font-medium text-12 leading-[18px] py-2 px-8 border-1 border-orange rounded-5 bg-bgCAlert ml-8 text-textCAlertLabel whitespace-nowrap">
      {t('components.mentoring.automation.mostPopularTag.mostPopular')}
    </div>
  )
}
