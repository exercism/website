import React, { useCallback, useState } from 'react'
import { Pagination } from '../common/Pagination'
import { TrackFilterList } from './queue/TrackFilterList'
import { useTrackList } from './queue/useTrackList'
import { Request } from '../../hooks/request-query'
import { Links } from './Queue'
import {
  AutomationStatus,
  MentoredTrack,
  MentoredTrackExercise,
} from '../types'
import { useMentoringQueue } from './queue/useMentoringQueue'
import { Sorter } from './Sorter'
import { SortOption } from './Inbox'
import { MOCK_DEFAULT_TRACK, MOCK_TRACKS } from './automation/mock-data'
import { StatusTab } from './inbox/StatusTab'

const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

const resolvedData = true

type AutomationProps = {
  tracksRequest: Request
  links: Links
  defaultTrack: MentoredTrack
  queueRequest: Request
  defaultExercise: MentoredTrackExercise | null
  sortOptions: SortOption[]
}

export function Automation({
  tracksRequest,
  sortOptions,
  links,
  defaultTrack,
  defaultExercise,
  queueRequest,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  const [status, setStatus] = useState<AutomationStatus>('need_feedback')
  const [selectedExercise, setSelectedExercise] =
    useState<MentoredTrackExercise | null>(defaultExercise)

  const { setCriteria, order, setOrder, setPage } = useMentoringQueue({
    request: queueRequest,
    track: selectedTrack,
    exercise: selectedExercise,
  })

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)
    },
    [setPage, setCriteria]
  )

  const {
    tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: TRACKS_LIST_CACHE_KEY,
    request: tracksRequest,
  })

  return (
    <div className="c-mentor-inbox">
      <div className="tabs">
        <StatusTab<AutomationStatus>
          status="need_feedback"
          currentStatus={status}
          setStatus={() => setStatus('need_feedback')}
        >
          Need feedback
          {resolvedData ? <div className="count">{12}</div> : null}
        </StatusTab>
        <StatusTab<AutomationStatus>
          status="feedback_submitted"
          currentStatus={status}
          setStatus={() => setStatus('feedback_submitted')}
        >
          Feedback submitted
          {resolvedData ? <div className="count">{15}</div> : null}
        </StatusTab>
      </div>
      <div className="container">
        <div className="c-search-bar">
          <TrackFilterList
            status={trackListStatus}
            error={trackListError}
            tracks={MOCK_TRACKS}
            isFetching={isTrackListFetching}
            cacheKey={TRACKS_LIST_CACHE_KEY}
            links={links}
            value={selectedTrack}
            setValue={handleTrackChange}
          />

          <input className="--search" placeholder="Filter by exercise" />
          <Sorter sortOptions={sortOptions} order={order} setOrder={setOrder} />
        </div>
        <Pagination
          setPage={() => console.log('page is set')}
          total={10}
          current={2}
        />
      </div>
    </div>
  )
}
