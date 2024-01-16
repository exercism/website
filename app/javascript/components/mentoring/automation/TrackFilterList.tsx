import React, { useCallback, useRef } from 'react'
import { TrackIcon, Icon } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'
import { AutomationTrack } from '../../types'
import { QueryKey, QueryStatus } from '@tanstack/react-query'
import { useDropdown } from '../../dropdowns/useDropdown'
import { ResultsZone } from '../../ResultsZone'
import { pluralizeWithNumber } from '../../../utils/pluralizeWithNumber'

type TrackFilterProps = AutomationTrack & {
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
  countText: string
}

const TrackFilter = ({
  title,
  iconUrl,
  numSubmissions,
  checked,
  onChange,
  countText,
}: TrackFilterProps): JSX.Element => {
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
        <div className="count">
          {pluralizeWithNumber(numSubmissions, countText)}
        </div>
      </div>
    </label>
  )
}

const DEFAULT_ERROR = new Error('Unable to fetch tracks')

export const TrackFilterList = ({
  status,
  error,
  children,
  ...props
}: React.PropsWithChildren<
  Props & { status: QueryStatus; error: unknown }
>): JSX.Element => {
  return (
    <FetchingBoundary
      error={error}
      status={status}
      defaultError={DEFAULT_ERROR}
    >
      <Component {...props}>{children}</Component>
    </FetchingBoundary>
  )
}

type Props = {
  tracks: AutomationTrack[] | undefined
  isFetching: boolean
  value: AutomationTrack
  setValue: (value: AutomationTrack) => void
  cacheKey: QueryKey
  sizeVariant?: 'large' | 'multi' | 'inline' | 'single' | 'automation'
  countText: string
}

const Component = ({
  sizeVariant = 'large',
  tracks,
  isFetching,
  value,
  setValue,
  countText,
}: Props): JSX.Element | null => {
  const changeTracksRef = useRef<HTMLButtonElement>(null)
  const {
    buttonAttributes,
    panelAttributes,
    listAttributes,
    itemAttributes,
    setOpen,
    open,
  } = useDropdown((tracks?.length || 0) + 1, (i) => handleItemSelect(i), {
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
  const handleItemSelect = useCallback(
    (index) => {
      if (!tracks) {
        return
      }

      const track = tracks[index]

      track ? setValue(tracks[index]) : changeTracksRef.current?.click()
      setOpen(false)
    },
    [setValue, tracks, setOpen]
  )

  if (!tracks) {
    return null
  }

  return (
    <div className={`c-single-select c-track-select --size-${sizeVariant}`}>
      <ResultsZone isFetching={isFetching}>
        <button
          className="current-track"
          aria-label="Open the track filter"
          {...buttonAttributes}
        >
          <TrackIcon iconUrl={value.iconUrl} title={value.title} />
          <div className="track-title">{value.title}</div>
          <div className="count">
            {pluralizeWithNumber(value.numSubmissions, countText)}
          </div>
          <Icon
            icon="chevron-down"
            alt="Click to change"
            className="action-icon"
          />
        </button>
      </ResultsZone>
      {open ? (
        <div {...panelAttributes} className="--options">
          <ul {...listAttributes}>
            {tracks.map((track, i) => {
              return (
                <li key={track.slug} {...itemAttributes(i)}>
                  <TrackFilter
                    countText={countText}
                    onChange={() => {
                      setValue(track)
                      setOpen(false)
                    }}
                    checked={value.slug === track.slug}
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
