import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const MarkAllAsSeenButton = ({
  unseenTotal,
  onClick,
}: {
  unseenTotal: number
  onClick: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/contribution-results')
  return (
    <button
      type="button"
      onClick={onClick}
      className="btn-m btn-default"
      disabled={unseenTotal === 0}
    >
      {t('markAllAsSeenButton.markAllAsSeen')}
    </button>
  )
}
