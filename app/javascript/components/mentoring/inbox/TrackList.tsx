import React, { useCallback } from 'react'
import { Icon, TrackIcon } from '../../common'
import { useDropdown } from '../../dropdowns/useDropdown'

type Track = {
  slug: string
  title: string
  iconUrl: string
  count: number
}

const TrackFilter = ({
  title,
  iconUrl,
  count,
  onChange,
  checked,
}: Track & { onChange: () => void; checked: boolean }) => {
  return (
    <React.Fragment>
      <label className="c-radio-wrapper">
        <input type="radio" onChange={onChange} checked={checked} />
        <div className="row">
          <div className="c-radio" />
          <TrackIcon iconUrl={iconUrl} title={title} />
          <div className="title">{title}</div>
          <div className="count">{count}</div>
        </div>
      </label>
    </React.Fragment>
  )
}

export const TrackList = ({
  tracks,
  value,
  setTrack,
}: {
  tracks: Track[]
  value: string | null
  setTrack: (value: string | null) => void
}): JSX.Element => {
  const handleItemSelect = useCallback(
    (index) => {
      setTrack(tracks[index].slug)
    },
    [setTrack, tracks]
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
  } = useDropdown(tracks.length, handleItemSelect)
  const selected = tracks.find((track) => track.slug === value) || tracks[0]

  if (!selected) {
    throw 'No matching track found'
  }

  return (
    <React.Fragment>
      <button
        aria-label="Button to open the track filter"
        {...buttonAttributes}
      >
        <TrackIcon iconUrl={selected.iconUrl} title={selected.title} />
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      <div className="c-track-switcher-dropdown" {...panelAttributes}>
        <ul {...listAttributes}>
          {tracks.map((track, i) => {
            return (
              <li key={track.slug} {...itemAttributes(i)}>
                <TrackFilter
                  onChange={() => setTrack(track.slug)}
                  checked={value === track.slug}
                  {...track}
                />
              </li>
            )
          })}
        </ul>
      </div>
    </React.Fragment>
  )
}
