// i18n-key-prefix: platformButton.linkedinButton
// i18n-namespace: components/common/share-panel
import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(
    `https://www.linkedin.com/shareArticle?url=${url}&title=${title}`
  )
}

export const LinkedinButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/share-panel')
  return (
    <a
      href={shareLink({ url, title })}
      className="linkedin"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-linkedin" />
      {t('platformButton.linkedinButton.linkedIn')}
    </a>
  )
}
