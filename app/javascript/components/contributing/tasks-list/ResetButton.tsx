// i18n-key-prefix: tasksList.resetButton
// i18n-namespace: components/contributing
import React from 'react'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ResetButton = ({
  onClick,
}: {
  onClick: () => void
}): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <button
      type="button"
      onClick={onClick}
      className="btn-m btn-link reset-btn"
    >
      <GraphicalIcon icon="reset" />
      <span>{t('tasksList.resetFilters')}</span>
    </button>
  )
}
