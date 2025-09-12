import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const InitializedOption = ({
  onCancelling,
  onUpdating,
}: {
  onCancelling: () => void
  onUpdating: () => void
}): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <div className="options">
      <button type="button" onClick={onUpdating} className="text-a-subtle">
        {t('formOptions.initializedOption.changeAmount')}
      </button>{' '}
      {t('formOptions.initializedOption.or')}{' '}
      <button type="button" onClick={onCancelling} className="text-a-subtle">
        {t('formOptions.initializedOption.cancelRecurringDonation')}
      </button>
    </div>
  )
}
