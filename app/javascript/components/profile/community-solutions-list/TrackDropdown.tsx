import React, { useCallback, useMemo } from 'react'
import { TrackIcon, Icon } from '../../common'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../../FetchingBoundary'
import { useDropdown } from '../../dropdowns/useDropdown'
import { usePaginatedRequestQuery, Request } from '../../../hooks/request-query'
import { Track } from '../../types'

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
        <div className="c-radio" />
        <TrackIcon iconUrl={iconUrl} title={title} />
        <div className="title">{title}</div>
        {numSolutions !== null ? (
          <div className="count">{numSolutions}</div>
        ) : null}
      </div>
    </label>
  )
}

const DEFAULT_ERROR = new Error('Unable to fetch tracks')

export const TrackDropdown = ({
  request,
  value,
  setValue,
}: {
  request: Request
  value: string
  setValue: (id: string | null) => void
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const { resolvedData, error, status } = usePaginatedRequestQuery<{
    tracks: readonly Track[]
  }>('joined-tracks', request, isMountedRef)
  const allTrack = useMemo(() => {
    return {
      title: 'All',
      id: null,
      /* TODO */
      iconUrl: '',
      numSolutions:
        resolvedData?.tracks
          .map((track) => track.numSolutions)
          .reduce((sum, x) => sum + x, 0) || null,
    }
  }, [resolvedData?.tracks])
  const tracks = useMemo(() => {
    return [allTrack, ...(resolvedData?.tracks || [])]
  }, [allTrack, resolvedData?.tracks])

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

  const selectedTrack = tracks.find((track) => track.id === value) || allTrack

  return (
    <FetchingBoundary
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    >
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
        {resolvedData?.tracks ? (
          <div className="count">{selectedTrack.numSolutions}</div>
        ) : null}
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
    </FetchingBoundary>
  )
}
