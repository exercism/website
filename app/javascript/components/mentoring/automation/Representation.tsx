import React from 'react'
import { QueryStatus } from 'react-query'
import { Checkbox, SearchInput } from '@/components/common'
import { ResultsZone } from '@/components/ResultsZone'
import { useAutomation } from './useAutomation'
import { TrackFilterList } from './TrackFilterList'
import { AutomationIntroducer } from './AutomationIntroducer'
import { RepresentationList } from './RepresentationList'
import { Sorter } from '../Sorter'
import { StatusTab } from '../inbox/StatusTab'
import { SortOption } from '../Inbox'
import type { Request } from '@/hooks'
import type { AutomationStatus, AutomationTrack } from '@/components/types'

export type AutomationLinks = {
  withFeedback?: string
  withoutFeedback?: string
  admin?: string
  hideIntroducer: string
}

export type SelectedTab = 'admin' | 'with_feedback' | 'without_feedback'
type TabCounts = Record<'admin' | 'withFeedback' | 'withoutFeedback', number>

export type AutomationProps = {
  tracks: AutomationTrack[]
  counts: TabCounts
  links: AutomationLinks
  representationsRequest: Request
  sortOptions: SortOption[]
  selectedTab: SelectedTab
  trackCacheKey: string
  isIntroducerHidden: boolean
}

export function Representations({
  tracks,
  counts,
  links,
  representationsRequest,
  sortOptions,
  selectedTab,
  trackCacheKey,
  isIntroducerHidden,
}: AutomationProps): JSX.Element {
  const withFeedback = selectedTab === 'with_feedback'
  const trackCountText = ['with_feedback', 'admin'].includes(selectedTab)
    ? 'submission'
    : 'request'
  const {
    status,
    error,
    isFetching,
    resolvedData,
    latestData,
    criteria,
    setCriteria,
    order,
    setOrder,
    page,
    setPage,
    checked,
    selectedTrack,
    handleTrackChange,
    handleOnlyMentoredSolutions,
    handlePageResetOnInputChange,
  } = useAutomation(representationsRequest, tracks)

  return (
    <div className="c-mentor-inbox">
      {!isIntroducerHidden && (
        <AutomationIntroducer hideEndpoint={links.hideIntroducer} />
      )}
      <div className="flex justify-between items-center">
        <div className="tabs">
          <StatusTab<AutomationStatus>
            status="without_feedback"
            currentStatus={selectedTab}
            setStatus={() => null}
          >
            <a href={links.withoutFeedback}>Need feedback</a>
            {resolvedData ? (
              <div className="count">{counts.withoutFeedback}</div>
            ) : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="with_feedback"
            currentStatus={selectedTab}
            setStatus={() => null}
          >
            <a href={links.withFeedback}>Feedback submitted</a>
            {resolvedData ? (
              <div className="count">{counts.withFeedback}</div>
            ) : null}
          </StatusTab>
          <StatusTab<AutomationStatus>
            status="admin"
            currentStatus={selectedTab}
            setStatus={() => null}
          >
            <a href={links.admin}>Admin</a>
            {resolvedData ? <div className="count">{counts.admin}</div> : null}
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
            status={QueryStatus.Success}
            error={''}
            tracks={tracks}
            countText={trackCountText}
            isFetching={false}
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
            status={status}
            error={error}
            withFeedback={withFeedback}
            selectedTab={selectedTab}
            latestData={latestData}
            page={page}
            setPage={setPage}
            resolvedData={resolvedData}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
