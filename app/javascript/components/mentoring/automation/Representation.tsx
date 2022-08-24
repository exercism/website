import React, { useCallback, useEffect, useState } from 'react'
import { TrackFilterList } from '../queue/TrackFilterList'
import { useTrackList } from '../queue/useTrackList'
import { Request, usePaginatedRequestQuery } from '../../../hooks/request-query'
import { AutomationStatus, MentoredTrack } from '../../types'
import { APIResponse } from './useMentoringAutomation'
import { Sorter } from '../Sorter'
import { MOCK_DEFAULT_TRACK } from './mock-data'
import { StatusTab } from '../inbox/StatusTab'
import { Checkbox } from '../../common'
import { AutomationIntroducer } from './AutomationIntroducer'
import SearchInput from '../../common/SearchInput'
import { ResultsZone } from '../../ResultsZone'
import { RepresentationList } from './RepresentationList'
import { SortOption } from '../Inbox'
import { useList } from '../../../hooks/use-list'
import { error } from 'jquery'
import { useHistory, removeEmpty } from '../../../hooks/use-history'
const TRACKS_LIST_CACHE_KEY = 'mentored-tracks'

export type AutomationLinks = {
  withFeedback: string
  withoutFeedback: string
}

export type AutomationProps = {
  tracksRequest: Request
  links: AutomationLinks
  representationsRequest: Request
  sortOptions: SortOption[]
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  // data: any
  withFeedback: boolean
}

export function Representations({
  tracksRequest,
  sortOptions,
  links,
  representationsRequest,
  withFeedback,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(representationsRequest)

  const [checked, setChecked] = useState(false)
  const [criteria, setCriteria] = useState(
    representationsRequest.query?.criteria || ''
  )

  const { status, resolvedData, latestData, isFetching } =
    usePaginatedRequestQuery<APIResponse>(
      ['mentor-representations-list', request.endpoint, request.query],
      request
    )

  useEffect(() => {
    console.log('request:', request)
  }, [request])

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 1000)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  // const setTrack = (trackSlug: string | null) => {
  //   setQuery({ ...request.query, trackSlug: trackSlug, page: undefined })
  // }

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)

      setQuery({ ...request.query, trackSlug: track.slug, page: undefined })
    },
    [setPage, setCriteria]
  )
  useEffect(() => {
    console.log('RESOLVED_DATA', resolvedData)
  }, [resolvedData])
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
            status="without_feedback"
            currentStatus={withFeedback ? 'with_feedback' : 'without_feedback'}
            setStatus={() => null}
          >
            <a href={links.withoutFeedback}>Need feedback</a>

            {resolvedData ? (
              <div className="count">
                {resolvedData.representations?.results?.length ??
                  resolvedData?.results?.length}
              </div>
            ) : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="with_feedback"
            currentStatus={withFeedback ? 'with_feedback' : 'without_feedback'}
            setStatus={() => null}
          >
            <a href={links.withFeedback}>Feedback submitted</a>
            {resolvedData ? (
              <div className="count">
                {resolvedData.representations?.results?.length ??
                  resolvedData?.results?.length}
              </div>
            ) : null}
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
            countText={'results'}
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
            order={request.query.order}
            setOrder={setOrder}
          />
        </header>
        <ResultsZone isFetching={isFetching}>
          <RepresentationList
            error={error}
            latestData={latestData?.representations ?? latestData}
            page={request.query.page}
            setPage={setPage}
            resolvedData={resolvedData?.representations ?? resolvedData}
            status={status}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
