import React, { useCallback, useRef } from 'react'
import { TrackFilterList } from './TrackFilterList'
import { Request } from '../../../hooks/request-query'
import { AutomationStatus } from '../../types'
import { Sorter } from '../Sorter'
import { StatusTab } from '../inbox/StatusTab'
import { Checkbox, SearchInput } from '../../common'
import { AutomationIntroducer } from './AutomationIntroducer'
import { ResultsZone } from '../../ResultsZone'
import { RepresentationList } from './RepresentationList'
import { SortOption } from '../Inbox'
import { error } from 'jquery'
import { useAutomation } from './useAutomation'

export type AutomationLinks = {
  withFeedback?: string
  withoutFeedback?: string
  hideIntroducer: string
}

export type AutomationProps = {
  tracksRequest: Request
  links: AutomationLinks
  representationsRequest: Request
  sortOptions: SortOption[]
  withFeedback: boolean
  representationsWithoutFeedbackCount?: number
  representationsWithFeedbackCount?: number
  trackCacheKey: string
  isIntroducerHidden: boolean
}

export function Representations({
  tracksRequest,
  sortOptions,
  links,
  representationsRequest,
  withFeedback,
  representationsWithoutFeedbackCount,
  representationsWithFeedbackCount,
  trackCacheKey,
  isIntroducerHidden,
}: AutomationProps): JSX.Element {
  const {
    feedbackCount,
    checked,
    handleTrackChange,
    isFetching,
    isTrackListFetching,
    latestData,
    order,
    page,
    resolvedData,
    selectedTrack,
    handleOnlyMentoredSolutions,
    setCriteria,
    setOrder,
    setPage,
    status,
    trackListError,
    trackListStatus,
    tracks,
    criteria,
  } = useAutomation(
    representationsRequest,
    representationsWithFeedbackCount,
    representationsWithoutFeedbackCount,
    tracksRequest,
    trackCacheKey,
    withFeedback
  )

  // timeout is stored in a useRef, so it can be cancelled
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const timer = useRef<any>()

  const handlePageResetOnInputChange = useCallback(
    (input: string) => {
      //clears it on any input
      clearTimeout(timer.current)
      if (criteria && (input.length > 2 || input.length === 0)) {
        timer.current = setTimeout(() => setPage(1), 500)
      }
    },

    [criteria, setPage]
  )

  return (
    <div className="c-mentor-inbox">
      {!isIntroducerHidden && (
        <AutomationIntroducer hideEndpoint={links.hideIntroducer} />
      )}
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
                {feedbackCount['without_feedback']?.toLocaleString()}
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
                {feedbackCount['with_feedback']?.toLocaleString()}
              </div>
            ) : null}
          </StatusTab>
        </div>
        {!withFeedback && (
          <Checkbox
            className="mb-20"
            checked={checked}
            setChecked={handleOnlyMentoredSolutions}
          >
            Only show solutions I&apos;ve mentored before
          </Checkbox>
        )}
      </div>
      <div className="container">
        <header className="c-search-bar automation-header">
          <TrackFilterList
            status={trackListStatus}
            error={trackListError}
            tracks={tracks}
            countText={withFeedback ? 'submission' : 'request'}
            isFetching={isTrackListFetching}
            cacheKey={trackCacheKey}
            value={selectedTrack}
            setValue={handleTrackChange}
            sizeVariant={'automation'}
          />

          <div className="flex flex-row flex-grow justify-between">
            <SearchInput
              className="mr-24"
              setFilter={(input) => {
                setCriteria(input)
                handlePageResetOnInputChange(input)
              }}
              filter={criteria}
              placeholder="Filter by exercise (min 3 chars)"
            />
            <Sorter
              componentClassName="automation-sorter"
              sortOptions={sortOptions}
              order={order}
              setOrder={setOrder}
              setPage={setPage}
            />
          </div>
        </header>
        <ResultsZone isFetching={isFetching}>
          <RepresentationList
            withFeedback={withFeedback}
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
