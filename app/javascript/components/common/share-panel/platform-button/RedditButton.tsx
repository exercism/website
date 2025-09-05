// i18n-key-prefix: platformButton.redditButton
// i18n-namespace: components/common/share-panel
import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  return encodeURI(`http://www.reddit.com/submit?url=${url}&title=${title}`)
}

export const RedditButton = ({
  url,
  title,
}: {
  url: string
  title: string
}): JSX.Element => {
  const { t } = useAppTranslation()
  return (
    <a
      href={shareLink({ url, title })}
      className="reddit"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-reddit" />
      {t('platformButton.redditButton.reddit')}
    </a>
  )
}
