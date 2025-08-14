import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'
import { usePanel } from '../../hooks/use-panel'
import { SharePanel } from './SharePanel'
import { SharePlatform } from '../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default function ShareButton({
  title,
  shareTitle,
  shareLink,
  platforms,
}: {
  title: string
  shareTitle: string
  shareLink: string
  platforms: readonly SharePlatform[]
}): JSX.Element {
  const { t } = useAppTranslation('components/common/ShareButton.tsx')
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
    placement: 'bottom-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 6],
        },
      },
    ],
  })

  return (
    <React.Fragment>
      <button
        className="c-share-button"
        type="button"
        {...buttonAttributes}
        onClick={() => setOpen(!open)}
      >
        <div className="inner">
          <GraphicalIcon icon="share-with-gradient" />
          {t('shareButton.share')}
        </div>
      </button>
      {open ? (
        <SharePanel
          title={title}
          url={shareLink}
          className="c-share-dropdown"
          shareTitle={shareTitle}
          platforms={platforms}
          {...panelAttributes}
        />
      ) : null}
    </React.Fragment>
  )
}
