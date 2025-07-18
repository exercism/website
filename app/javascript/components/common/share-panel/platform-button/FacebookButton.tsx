// i18n-key-prefix: platformButton.facebookButton
// i18n-namespace: components/common/share-panel
import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const shareLink = ({ url }: { url: string }) => {
  return encodeURI(`https://www.facebook.com/share.php?u=${url}`)
}

export const FacebookButton = ({ url }: { url: string }): JSX.Element => {
  const { t } = useAppTranslation('components/common/share-panel')
  return (
    <a
      href={shareLink({ url })}
      className="facebook"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-facebook" />
      {t('platformButton.facebookButton.facebook')}
    </a>
  )
}
