import React from 'react'
import { GraphicalIcon, TrackIcon } from '../../common'
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
      <label className="c-checkbox-wrapper">
        <input type="checkbox" onChange={onChange} checked={checked} />
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        <TrackIcon iconUrl={iconUrl} title={title} />
        <div className="title">{title}</div>
        <div className="count">{count}</div>
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
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
  } = useDropdown(tracks.length)
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
      </button>
      <div {...panelAttributes}>
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
