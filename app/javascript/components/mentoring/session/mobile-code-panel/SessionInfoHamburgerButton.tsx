import React from 'react'
import Icon from '@/components/common/Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function SessionInfoHamburgerButton({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  const { t } = useAppTranslation(
    'components/mentoring/session/mobile-code-panel/SessionInfoHamburgerButton.tsx'
  )
  return (
    <button
      className="btn-s btn-default download-btn"
      type="button"
      onClick={onClick}
    >
      <Icon
        icon="hamburger"
        alt={t('sessionInfoHamburgerButton.downloadSolution')}
      />
    </button>
  )
}
