import React, { useCallback, useRef } from 'react'
import { QueryStatus } from 'react-query'
import { AutomationTrack, VideosTrack } from '@/components/types'
import { pluralizeWithNumber } from '@/utils/pluralizeWithNumber'
import { TrackIcon, Icon } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'
import { useDropdown } from '../../dropdowns/useDropdown'
import { ResultsZone } from '../../ResultsZone'

type TrackFilterProps = VideosTrack & {
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
  countText: string
}

const TrackFilter = ({
  title,
  iconUrl,
  numVideos,
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
        {/* TODO: Add video counts here */}
        {/* <div className="count">{pluralizeWithNumber(numVideos, countText)}</div> */}
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
  cacheKey: string
  sizeVariant?: 'large' | 'multi' | 'inline' | 'single' | 'automation'
  countText: string
  // TODO remove this
  numVideos?: number
}

const Component = ({
  sizeVariant = 'large',
  tracks,
  isFetching,
  value,
  setValue,
  // TODO remove this
  numVideos = 100,
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
          className="current-track !shadow-xsZ1v2"
          aria-label="Open the track filter"
          {...buttonAttributes}
        >
          <TrackIcon iconUrl={value.iconUrl} title={value.title} />
          <div className="track-title">{value.title}</div>
          <div className="count">
            {/* TODO change this back to value.numVideos once data is there */}
            {/* {pluralizeWithNumber(numVideos, countText)} */}
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
                    numVideos={Math.round(Math.random() * 100)}
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
