import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ContinueButton = (
  props: React.ButtonHTMLAttributes<HTMLButtonElement>
): JSX.Element => {
  const { t } = useAppTranslation('components/mentoring/track-selector')

  return (
    <button className="btn-primary btn-m" {...props}>
      <span>{t('continueButton.continue')}</span>
    </button>
  )
}
