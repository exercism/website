import React, { useCallback, useEffect, useState } from 'react'
import { TrackFilterList } from '../queue/TrackFilterList'
import { useTrackList } from '../queue/useTrackList'
import { Request } from '../../../hooks/request-query'
import { AutomationStatus, MentoredTrack } from '../../types'
import { useMentoringQueue } from '../queue/useMentoringQueue'
import { Sorter } from '../Sorter'
import { MOCK_DEFAULT_TRACK } from './mock-data'
import { StatusTab } from '../inbox/StatusTab'
import { Checkbox } from '../../common'
import { AutomationIntroducer } from './AutomationIntroducer'
import SearchInput from '../../common/SearchInput'
import { ResultsZone } from '../../ResultsZone'
import { RepresentationList } from './RepresentationList'
import { SortOption } from '../Inbox'
import { Links } from '../Queue'
const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

export type AutomationProps = {
  tracks_request: Request
  links: Links
  // defaultTrack: MentoredTrack
  representations_request: Request
  sort_options: SortOption[]
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: any
  withFeedback: boolean
}

export function Representations({
  tracks_request,
  sort_options,
  links,
  representations_request,
  data,
  withFeedback,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  const [checked, setChecked] = useState(false)

  console.log('tracks REQ', tracks_request)

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
    request: representations_request,
    exercise: null,
    track: null,
  })

  useEffect(() => {
    console.log('SELECTED_TRACK', resolvedData)
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
    request: tracks_request,
  })

  return (
    <div className="c-mentor-inbox">
      <AutomationIntroducer />
      <div className="flex justify-between">
        <div className="tabs">
          <StatusTab<AutomationStatus>
            status="without_feedback"
            currentStatus={withFeedback ? 'with_feedback' : 'without_feedback'}
            setStatus={() => null}
          >
            <a href={links.without_feedback}>Need feedback</a>

            {resolvedData ? <div className="count">{12}</div> : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="with_feedback"
            currentStatus={withFeedback ? 'with_feedback' : 'without_feedback'}
            setStatus={() => null}
          >
            <a href={links.with_feedback}>Feedback submitted</a>
            {resolvedData ? <div className="count">{15}</div> : null}
          </StatusTab>
        </div>
        {!withFeedback && (
          <Checkbox checked={checked} setChecked={() => setChecked((c) => !c)}>
            Only show solutions I&apos;ve mentored before
          </Checkbox>
        )}
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
            sortOptions={sort_options}
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
