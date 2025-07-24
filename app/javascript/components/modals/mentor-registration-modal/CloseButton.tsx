// i18n-key-prefix: closeButton
// i18n-namespace: components/modals/mentor-registration-modal
import React from 'react'
import { Icon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CloseButton = ({
  onClick,
}: {
  onClick: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/mentor-registration-modal')
  return (
    <button type="button" className="close-btn" onClick={onClick}>
      <Icon
        icon="close"
        alt={t('closeButton.closeModal')}
        className="filter-textColor6"
      />
    </button>
  )
}
