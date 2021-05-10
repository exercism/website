import React from 'react'
import { GraphicalIcon } from './GraphicalIcon'
import { usePanel } from '../../hooks/use-panel'
import { SharePanel } from './SharePanel'

type Links = {
  solution: string
}

export const ShareSolutionButton = ({
  title,
  links,
}: {
  title: string
  links: Links
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
        className="share-button"
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
          textToCopy={links.solution}
          className="c-share-solution-dropdown"
          {...panelAttributes}
        />
      ) : null}
    </React.Fragment>
  )
}
