import React from 'react'
import { GraphicalIcon } from '../../common'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const CloseButton = ({ url }: { url: string }): JSX.Element => {
  const { t } = useAppTranslation(
    'components/mentoring/session/CloseButton.tsx'
  )
  return (
    <a
      href={url}
      className="close-btn"
      aria-label={t('closeButton.returnToDashboard')}
    >
      <GraphicalIcon icon="close" />
    </a>
  )
}
