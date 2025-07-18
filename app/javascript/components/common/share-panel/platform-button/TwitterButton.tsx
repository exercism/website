// i18n-key-prefix: platformButton.twitterButton
// i18n-namespace: components/common/share-panel
import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(`https://twitter.com/intent/tweet?url=${url}&title=${title}`)
}

export const TwitterButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/share-panel')
  return (
    <a
      href={shareLink({ url, title: title })}
      className="twitter"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-twitter" />
      {t('platformButton.twitterButton.twitter')}
    </a>
  )
}
