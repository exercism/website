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
import useLogger from '../../../hooks/use-logger'
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
  representationsWithoutFeedbackCount?: number
  representationsWithFeedbackCount?: number
}

export function Representations({
  tracksRequest,
  sortOptions,
  links,
  representationsRequest,
  withFeedback,
  representationsWithoutFeedbackCount,
  representationsWithFeedbackCount,
}: AutomationProps): JSX.Element {
  const [selectedTrack, setSelectedTrack] =
    useState<MentoredTrack>(MOCK_DEFAULT_TRACK)

  // TODO: Move these into a separate hook
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
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 1000)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const handleTrackChange = useCallback(
    (track) => {
      setPage(1)
      setCriteria('')
      setSelectedTrack(track)

      setQuery({ ...request.query, trackSlug: track.slug, page: undefined })
    },
    [setPage, setQuery, request.query]
  )

  const feedbackCount = useCallback(
    (withFeedback) => {
      if (withFeedback) {
        return {
          with_feedback: resolvedData?.results.length,
          without_feedback: representationsWithoutFeedbackCount,
        }
      } else {
        return {
          with_feedback: representationsWithFeedbackCount,
          without_feedback: resolvedData?.results.length,
        }
      }
    },
    [
      representationsWithFeedbackCount,
      representationsWithoutFeedbackCount,
      resolvedData?.results.length,
    ]
  )

  const {
    resolvedData: tracks,
    status: trackListStatus,
    error: trackListError,
    isFetching: isTrackListFetching,
  } = useTrackList({
    cacheKey: TRACKS_LIST_CACHE_KEY,
    request: tracksRequest,
  })

  useLogger('resolvedData:', links)

  return (
    <div className="c-mentor-inbox">
      <AutomationIntroducer />
      <div className="flex justify-between items-center">
        <div className="tabs">
          <StatusTab<AutomationStatus>
            status="without_feedback"
            currentStatus={withFeedback ? 'with_feedback' : 'without_feedback'}
            setStatus={() => null}
          >
            <a href={links.withoutFeedback}>Need feedback</a>

            {resolvedData ? (
              <div className="count">
                {feedbackCount(withFeedback)['without_feedback']}
              </div>
            ) : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="with_feedback"
            currentStatus={withFeedback ? 'with_feedback' : 'without_feedback'}
            setStatus={() => null}
          >
            {/* TODO: this routing is pretty bad.. */}
            <a href={links.withFeedback}>Feedback submitted</a>
            {resolvedData ? (
              <div className="count">
                {feedbackCount(withFeedback)['with_feedback']}
              </div>
            ) : null}
          </StatusTab>
        </div>
        {!withFeedback && (
          <Checkbox
            className="mb-20"
            checked={checked}
            setChecked={() => setChecked((c) => !c)}
          >
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
            // TODO: work more on the responsivity of this style
            sizeVariant={'automation'}
          />

          <div className="flex flex-row flex-grow justify-between">
            <SearchInput
              className="mr-24"
              setFilter={setCriteria}
              filter={criteria}
              placeholder="Filter by exercise"
            />
            <Sorter
              componentClassName="automation-sorter"
              sortOptions={sortOptions}
              order={request.query.order}
              setOrder={setOrder}
            />
          </div>
        </header>
        <ResultsZone isFetching={isFetching}>
          <RepresentationList
            error={error}
            latestData={latestData}
            page={request.query.page}
            setPage={setPage}
            resolvedData={resolvedData}
            status={status}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
