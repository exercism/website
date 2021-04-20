import React, { useCallback, useMemo } from 'react'
import { TrackIcon, Icon } from '../../common'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../../FetchingBoundary'
import { useDropdown } from '../../dropdowns/useDropdown'
import { Track } from '../../types'
import { TrackData } from '../CommunitySolutionsList'

const TrackFilter = ({
  title,
  iconUrl,
  numSolutions,
  checked,
  onChange,
}: {
  title: string
  iconUrl: string
  numSolutions: number | null
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
}): JSX.Element => {
  return (
    <label className="c-radio-wrapper">
      <input
        type="radio"
        onChange={onChange}
        checked={checked}
        name="queue_track"
      />
      <div className="row">
        <TrackIcon iconUrl={iconUrl} title={title} />
        <div className="title">{title}</div>
        <div className="count">{numSolutions}</div>
      </div>
    </label>
  )
}

const DEFAULT_ERROR = new Error('Unable to fetch tracks')

export const TrackDropdown = ({
  tracks,
  value,
  setValue,
}: {
  tracks: TrackData[]
  value: string
  setValue: (id: string | null) => void
}): JSX.Element | null => {
  const handleItemSelect = useCallback(
    (index) => {
      const track = tracks[index]

      setValue(track.id)
    },
    [setValue, tracks]
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown(tracks.length, handleItemSelect, {
    placement: 'bottom',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })

  const selectedTrack = tracks.find((track) => track.id === value) || tracks[0]

  return (
    <div className="c-track-switcher --small">
      <button
        className="current-track"
        aria-label="Open the track filter"
        {...buttonAttributes}
      >
        <TrackIcon
          iconUrl={selectedTrack.iconUrl}
          title={selectedTrack.title}
        />
        <div className="track-title">{selectedTrack.title}</div>
        <div className="count">{selectedTrack.numSolutions}</div>
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div {...panelAttributes} className="c-track-switcher-dropdown">
          <ul {...listAttributes}>
            {tracks.map((track, i) => {
              return (
                <li key={track.id} {...itemAttributes(i)}>
                  <TrackFilter
                    onChange={() => {
                      setValue(track.id)
                      setOpen(false)
                    }}
                    checked={track.id === value}
                    {...track}
                  />
                </li>
              )
            })}
          </ul>
        </div>
      ) : null}
    </div>
  )
}
