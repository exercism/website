// i18n-key-prefix: loadingOverlay
// i18n-namespace: components/test
import React, { useCallback } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { redirectTo } from '../../utils/redirect-to'

export const LoadingOverlay = ({ url }: { url: string }): JSX.Element => {
  const { t } = useAppTranslation()
  const handleClick = useCallback(() => {
    redirectTo(url)
  }, [url])

  return <button onClick={handleClick}>{t('loadingOverlay.redirect')}</button>
}
