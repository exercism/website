import React, { useCallback } from 'react'
import { Icon, TrackIcon } from '../../common'
import { useDropdown } from '../../dropdowns/useDropdown'
import { Track } from '../TestimonialsList'

const TrackFilter = ({
  title,
  iconUrl,
  onChange,
  checked,
}: Track & { onChange: () => void; checked: boolean }) => {
  return (
    <label className="c-radio-wrapper">
      <input type="radio" onChange={onChange} checked={checked} />
      <div className="row">
        <TrackIcon iconUrl={iconUrl} title={title} />
        <div className="title">{title}</div>
      </div>
    </label>
  )
}

export const TrackDropdown = ({
  tracks,
  value,
  setValue,
}: {
  tracks: readonly Track[]
  value: string
  setValue: (value: string) => void
}): JSX.Element => {
  const handleItemSelect = useCallback(
    (index) => {
      setValue(tracks[index].slug)
    },
    [setValue, tracks]
  )
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    open,
    setOpen,
  } = useDropdown(tracks.length, handleItemSelect, {
    placement: 'bottom-end',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [-8, 8],
        },
      },
    ],
  })
  const selected = tracks.find((track) => track.slug === value) || tracks[0]

  return (
    <div className="c-track-filter">
      <button
        aria-label="Open the track filter"
        {...buttonAttributes}
        style={{ width: '100px' }}
      >
        <TrackIcon iconUrl={selected.iconUrl} title={selected.title} />
        <Icon
          icon="chevron-down"
          alt="Click to change"
          className="action-icon"
        />
      </button>
      {open ? (
        <div className="c-track-switcher-dropdown" {...panelAttributes}>
          <ul {...listAttributes}>
            {tracks.map((track, i) => {
              return (
                <li key={track.slug} {...itemAttributes(i)}>
                  <TrackFilter
                    onChange={() => {
                      setValue(track.slug)
                      setOpen(false)
                    }}
                    checked={value === track.slug}
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
