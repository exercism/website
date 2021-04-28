import React from 'react'
import { useDropdown } from './useDropdown'
import { Track } from '../types'

type Links = {
  repo: string
  documentation: string
}

export const TrackMenu = ({
  track,
  links,
}: {
  track: Track
  links: Links
}): JSX.Element => {
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(4, undefined, {
    placement: 'bottom-start',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  return (
    <React.Fragment>
      <button {...buttonAttributes}>Track menu</button>
      {open ? (
        <div {...panelAttributes}>
          <ul {...listAttributes}>
            <li {...itemAttributes(0)}>
              <a href={links.repo} target="_blank" rel="noreferrer">
                See {track.title} track on Github
              </a>
            </li>
            <li {...itemAttributes(1)}>
              <a href={links.documentation} target="_blank" rel="noreferrer">
                {track.title} documentation
              </a>
            </li>
          </ul>
        </div>
      ) : null}
    </React.Fragment>
  )
}
