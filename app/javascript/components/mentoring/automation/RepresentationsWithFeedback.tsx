import React, { useCallback, useEffect, useState } from 'react'
import { TrackFilterList } from '../queue/TrackFilterList'
import { useTrackList } from '../queue/useTrackList'
import { Request } from '../../../hooks/request-query'
import { Links } from '../Queue'
import {
  AutomationStatus,
  MentoredTrack,
  MentoredTrackExercise,
} from '../../types'
import { useMentoringQueue } from '../queue/useMentoringQueue'
import { Sorter } from '../Sorter'
import { SortOption } from '../Inbox'
import { MOCK_DEFAULT_TRACK, MOCK_LIST_ELEMENT } from './mock-data'
import { StatusTab } from '../inbox/StatusTab'
import { Checkbox } from '../../common'
import { AutomationIntroducer } from './AutomationIntroducer'
import SearchInput from '../../common/SearchInput'
import { ResultsZone } from '../../ResultsZone'
import { RepresentationList } from './RepresentationList'

const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

// const MOCK_LIST = new Array(24).fill(MOCK_LIST_ELEMENT)

type AutomationProps = {
  tracksRequest: Request
  links: Links
  // defaultTrack: MentoredTrack
  representationsRequest: Request
  defaultExercise: MentoredTrackExercise | null
  sortOptions: SortOption[]
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: any
}

export function RepresentationsWithFeedback({
  tracksRequest,
  sortOptions,
  links,
  defaultExercise,
  representationsRequest,
  data,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  const [checked, setChecked] = useState(false)

  const [autoStatus, setStatus] = useState<AutomationStatus>('need_feedback')
  const [selectedExercise] = useState<MentoredTrackExercise | null>(
    defaultExercise
  )

  console.log('REP REQ', representationsRequest)

  const {
    resolvedData,
    isFetching,
    criteria,
    setCriteria,
    error,
    latestData,
    order,
    setOrder,
    page,
    setPage,
    status,
  } = useMentoringQueue({
    request: representationsRequest,
    track: selectedTrack,
    exercise: selectedExercise,
  })

  useEffect(() => {
    console.log('RESOLVED_DATA:', resolvedData)
  }, [resolvedData])

  console.log('DATA:', data)

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
      <AutomationIntroducer />
      <div className="flex justify-between">
        <div className="tabs">
          <StatusTab<AutomationStatus>
            status="need_feedback"
            currentStatus={autoStatus}
            setStatus={() => setStatus('need_feedback')}
          >
            Need feedback
            {resolvedData ? <div className="count">{12}</div> : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="feedback_submitted"
            currentStatus={autoStatus}
            setStatus={() => setStatus('feedback_submitted')}
          >
            Feedback submitted
            {resolvedData ? <div className="count">{15}</div> : null}
          </StatusTab>
        </div>
        <Checkbox checked={checked} setChecked={() => setChecked((c) => !c)}>
          Only show solutions I&apos;ve mentored before
        </Checkbox>
      </div>
      <div className="container">
        <header className="c-search-bar automation-header">
          <TrackFilterList
            countText={'requests'}
            status={trackListStatus}
            error={trackListError}
            tracks={tracks}
            isFetching={isTrackListFetching}
            cacheKey={TRACKS_LIST_CACHE_KEY}
            links={links}
            value={selectedTrack}
            setValue={handleTrackChange}
            sizeVariant={'automation'}
          />

          <SearchInput
            setFilter={setCriteria}
            filter={criteria}
            placeholder="Filter by exercise"
          />
          <Sorter
            componentClassName="ml-auto automation-sorter"
            sortOptions={sortOptions}
            order={order}
            setOrder={setOrder}
          />
        </header>
        <ResultsZone isFetching={isFetching}>
          <RepresentationList
            error={error}
            latestData={latestData}
            page={page}
            setPage={setPage}
            resolvedData={resolvedData}
            status={status}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
