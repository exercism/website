// i18n-key-prefix: firstRow
// i18n-namespace: components/track/build/analyzer-tags
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function FirstRow(): JSX.Element {
  const { t } = useAppTranslation('components/track/build/analyzer-tags')
  return (
    <div className="record-row sticky z-1 lg:top-0 top-[65px]">
      <div className="record-name" />
      <div className="record-value">
        <div className="record-element">{t('firstRow.tag')}</div>
        <div className="record-element justify-end">
          {t('firstRow.enabled')}
        </div>
        <div className="record-element justify-end">
          {t('firstRow.filterable')}
        </div>
        <div className="record-element justify-end">
          {t('firstRow.numSolutions')}
        </div>
      </div>
    </div>
  )
}
