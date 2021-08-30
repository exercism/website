import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'
import { usePanel } from '../../hooks/use-panel'
import { SharePanel } from './SharePanel'

export const ShareButton = ({
  title,
  shareTitle,
  shareLink,
}: {
  title: string
  shareTitle: string
  shareLink: string
}): JSX.Element => {
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
          Share
        </div>
      </button>
      {open ? (
        <SharePanel
          title={title}
          url={shareLink}
          className="c-share-solution-dropdown"
          shareTitle={shareTitle}
          {...panelAttributes}
        />
      ) : null}
    </React.Fragment>
  )
}
