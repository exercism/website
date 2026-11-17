import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const InitializedOption = ({
  updateCardLink,
  onCancelling,
  onUpdating,
}: {
  updateCardLink: string
  onCancelling: () => void
  onUpdating: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/donations/subscription-form')
  return (
    <div className="options">
      <button type="button" onClick={onUpdating} className="text-a-subtle">
        {t('formOptions.initializedOption.changeAmount')}
      </button>
      {', '}
      <a href={updateCardLink} className="text-a-subtle">
        {t('formOptions.initializedOption.updateCard')}
      </a>{' '}
      {t('formOptions.initializedOption.or')}{' '}
      <button type="button" onClick={onCancelling} className="text-a-subtle">
        {t('formOptions.initializedOption.cancelDonation')}
      </button>
    </div>
  )
}
