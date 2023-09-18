import React from 'react'
import { usePanel } from '@/hooks/use-panel'
import { SharePanel } from './SharePanel'
import { SharePlatform } from '../types'

export default function ShareLink({
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
        className="text-textColor2 font-medium border-b-1 border-borderColor6"
        type="button"
        {...buttonAttributes}
        onClick={() => setOpen(!open)}
      >
        Share it.
      </button>
      {open ? (
        <SharePanel
          title={title}
          url={shareLink}
          shareTitle={shareTitle}
          platforms={platforms}
          className="c-share-dropdown"
          {...panelAttributes}
        />
      ) : null}
    </React.Fragment>
  )
}
