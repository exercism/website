// i18n-key-prefix: platformButton.devToButton
// i18n-namespace: components/common/share-panel
import React from 'react'
import { GraphicalIcon } from '../../GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const shareLink = ({ url, title }: { url: string; title: string }) => {
  const markdown = `
    ---
    title: ${title}
    ---
    ${url}
  `

  return `https://dev.to/new?prefill=${encodeURI(markdown)}`
}

export const DevToButton = ({
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
      className="devto"
      target="_blank"
      rel="noreferrer"
    >
      <GraphicalIcon icon="external-site-devto" />
      {t('platformButton.devToButton.devTo')}
    </a>
  )
}
