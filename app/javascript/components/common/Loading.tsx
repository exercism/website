// i18n-key-prefix:
// i18n-namespace: components/common/Loading.tsx
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Loading() {
  const { t } = useAppTranslation('components/common/Loading.tsx')
  return (
    <div className="c-loading" role="alert">
      <span className="sr-only">{t('loading')}</span>
    </div>
  )
}
