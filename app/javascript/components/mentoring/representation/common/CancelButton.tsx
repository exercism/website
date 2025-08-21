// i18n-key-prefix: cancelButton
// i18n-namespace: components/mentoring/representation/common
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CancelButton({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  const { t } = useAppTranslation('components/mentoring/representation/common')
  return (
    <button
      onClick={onClick}
      className="mr-16 px-[18px] py-[12px] border border-1 border-textColor1 text-textColor1 text-16 rounded-8 font-semibold shadow-xsZ1v2"
    >
      {t('cancelButton.cancel')}
    </button>
  )
}
