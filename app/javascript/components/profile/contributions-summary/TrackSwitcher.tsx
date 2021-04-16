import React, { useCallback } from 'react'
import { TrackIcon, Icon, GraphicalIcon } from '../../common'
import { Track, getTotalReputation } from '../ContributionsSummary'
import { useDropdown } from '../../dropdowns/useDropdown'

const TrackLogo = ({ track }: { track: Track }) => {
  return track.id === 'all' ? (
    <GraphicalIcon icon="logo" />
  ) : (
    <TrackIcon iconUrl={track.iconUrl} title={track.title} />
  )
}

const TrackFilter = ({
  track,
  checked,
  onChange,
}: {
  track: Track
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
        <TrackLogo track={track} />
        <div className="title">{track.title}</div>
        <div className="count">{getTotalReputation(track)} rep</div>
      </div>
    </label>
  )
}

export const TrackSwitcher = ({
  tracks,
  value,
  setValue,
}: {
  tracks: readonly Track[]
  value: Track
  setValue: (value: Track) => void
}): JSX.Element | null => {
  const handleItemSelect = useCallback(
    (index) => {
      setValue(tracks[index])
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

  return (
    <div className="c-track-switcher">
      <button
        className="current-track"
        aria-label="Open the track switcher"
        {...buttonAttributes}
      >
        <GraphicalIcon icon="logo" />
        <div className="track-title">{value.title}</div>
        <div className="count">{getTotalReputation(value)} rep</div>
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
                      setValue(track)
                      setOpen(false)
                    }}
                    checked={value.id === track.id}
                    track={track}
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
