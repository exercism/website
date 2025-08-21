// i18n-key-prefix: checkCodeButton
// i18n-namespace: components/bootcamp/CustomFunctionEditor
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CheckCodeButton({
  handleRunCode,
}: {
  handleRunCode: () => void
}) {
  const { t } = useAppTranslation('components/bootcamp/CustomFunctionEditor')
  return (
    <button
      onClick={handleRunCode}
      className="scenarios-button flex btn-primary btn-xs"
    >
      {t('checkCodeButton.checkCode')}
    </button>
  )
}
