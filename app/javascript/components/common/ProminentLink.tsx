// i18n-namespace: components/common/ProminentLink.tsx
import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'
import { Icon } from './Icon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ProminentLink = ({
  link,
  text,
  withBg,
  external,
}: {
  link: string
  text: string
  withBg?: boolean
  external?: boolean
}): JSX.Element => {
  const { t } = useAppTranslation('components/common/ProminentLink.tsx')
  const className = ['c-prominent-link', withBg ? '--with-bg' : ''].join(' ')

  if (external) {
    return (
      <a href={link} className={className} target="_blank" rel="noreferrer">
        <span>{text}</span>
        <Icon icon="external-link" alt={t('prominentLink.opensInNewWindow')} />
      </a>
    )
  } else {
    return (
      <a href={link} className={className}>
        <span>{text}</span>
        <GraphicalIcon icon="arrow-right" />
      </a>
    )
  }
}
