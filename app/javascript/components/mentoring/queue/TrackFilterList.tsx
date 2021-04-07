import React, { useCallback, useRef, useState } from 'react'
import { TrackIcon, Icon, GraphicalIcon } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'
import { MentoredTrack } from '../../types'
import { QueryStatus } from 'react-query'
import { useDropdown } from '../../dropdowns/useDropdown'
import { ResultsZone } from '../../ResultsZone'
import { MentorChangeTracksModal } from '../../modals/MentorChangeTracksModal'

const TrackFilter = ({
  title,
  iconUrl,
  numSolutionsQueued,
  checked,
  onChange,
}: MentoredTrack & {
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
        <div className="count">{numSolutionsQueued}</div>
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
  tracks: MentoredTrack[] | undefined
  isFetching: boolean
  value: MentoredTrack | null
  setValue: (value: MentoredTrack) => void
  cacheKey: string
  total?: number
  links: {
    tracks: string
    updateTracks: string
  }
}

const Component = ({
  tracks,
  isFetching,
  value,
  setValue,
  cacheKey,
  links,
  total,
}: Props): JSX.Element | null => {
  const changeTracksRef = useRef<HTMLButtonElement>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const handleItemSelect = useCallback(
    (index) => {
      if (!tracks) {
        return
      }

      const track = tracks[index]

      track ? setValue(tracks[index]) : changeTracksRef.current?.click()
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
  } = useDropdown((tracks?.length || 0) + 1, handleItemSelect, {
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

  if (!tracks) {
    return null
  }

  const selected = tracks.find((track) => track === value) || tracks[0]

  return (
    <React.Fragment>
      <ResultsZone isFetching={isFetching}>
        <button
          className="current-track"
          aria-label="Open the track filter"
          {...buttonAttributes}
        >
          <TrackIcon iconUrl={selected.iconUrl} title={selected.title} />
          <div className="track-title">{selected.title}</div>
          {total !== undefined ? <div className="count">{total}</div> : null}
          <Icon
            icon="chevron-down"
            alt="Click to change"
            className="action-icon"
          />
        </button>
      </ResultsZone>
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
                    checked={value === track}
                    {...track}
                  />
                </li>
              )
            })}
            <li key="change-tracks" {...itemAttributes(tracks.length)}>
              <button
                ref={changeTracksRef}
                type="button"
                onClick={() => {
                  setIsModalOpen(true)
                  setOpen(false)
                }}
              >
                <GraphicalIcon icon="reset" />
                Change the tracks you mentor
              </button>
            </li>
          </ul>
        </div>
      ) : null}
      <MentorChangeTracksModal
        open={isModalOpen}
        tracks={tracks}
        cacheKey={cacheKey}
        links={links}
        onClose={() => setIsModalOpen(false)}
        onSuccess={() => {
          setIsModalOpen(false)
          setOpen(false)
        }}
      />
    </React.Fragment>
  )
}
