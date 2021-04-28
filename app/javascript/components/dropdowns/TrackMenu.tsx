import React, { useState } from 'react'
import { useDropdown } from './useDropdown'
import { Track } from '../types'
import { ActivatePracticeModeModal } from './track-menu/ActivatePracticeModeModal'
import { ResetTrackModal } from './track-menu/ResetTrackModal'
import { LeaveTrackModal } from './track-menu/LeaveTrackModal'

type Links = {
  repo: string
  documentation: string
  practice: string
  reset: string
  leave: string
}

type ModalType = 'practice' | 'reset' | 'leave'

export const TrackMenu = ({
  track,
  links,
}: {
  track: Track
  links: Links
}): JSX.Element => {
  const [modal, setModal] = useState<ModalType | null>(null)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
  } = useDropdown(5, undefined, {
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
            <li {...itemAttributes(2)}>
              <button type="button" onClick={() => setModal('practice')}>
                Activate practice mode
              </button>
            </li>
            <li {...itemAttributes(3)}>
              <button type="button" onClick={() => setModal('reset')}>
                Reset track
              </button>
            </li>
            <li {...itemAttributes(4)}>
              <button type="button" onClick={() => setModal('leave')}>
                Leave track
              </button>
            </li>
          </ul>
        </div>
      ) : null}
      <React.Fragment>
        <ActivatePracticeModeModal
          open={modal === 'practice'}
          onClose={() => setModal(null)}
          endpoint={links.practice}
        />
        <ResetTrackModal
          open={modal === 'reset'}
          onClose={() => setModal(null)}
          endpoint={links.reset}
        />
        <LeaveTrackModal
          open={modal === 'leave'}
          onClose={() => setModal(null)}
          endpoint={links.leave}
        />
      </React.Fragment>
    </React.Fragment>
  )
}
