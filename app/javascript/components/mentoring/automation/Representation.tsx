import React from 'react'
import { Checkbox, SearchInput } from '@/components/common'
import { ResultsZone } from '@/components/ResultsZone'
import { useAutomation } from './useAutomation'
import { TrackFilterList } from './TrackFilterList'
import { AutomationIntroducer } from './AutomationIntroducer'
import { RepresentationList } from './RepresentationList'
import { Sorter } from '../Sorter'
import { StatusTabLink } from '../inbox/StatusTab'
import { SortOption } from '../Inbox'
import type { Request } from '@/hooks/request-query'
import type { AutomationStatus, AutomationTrack } from '@/components/types'
import { QueryKey } from '@tanstack/react-query'

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
  trackCacheKey: QueryKey
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
    : 'representation'
  const {
    status,
    error,
    isFetching,
    resolvedData,
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
  } = useAutomation(representationsRequest, tracks, selectedTab)

  return (
    <div className="c-mentor-automation">
      {!isIntroducerHidden && (
        <AutomationIntroducer hideEndpoint={links.hideIntroducer} />
      )}
      <div className="flex justify-between items-center">
        <div className="tabs">
          <StatusTabLink<AutomationStatus>
            status="without_feedback"
            currentStatus={selectedTab}
            href={links.withoutFeedback!}
          >
            Need feedback
            {resolvedData ? (
              <div className="count">
                {counts.withoutFeedback.toLocaleString()}
              </div>
            ) : null}
          </StatusTabLink>
          <StatusTabLink<AutomationStatus>
            status="with_feedback"
            currentStatus={selectedTab}
            href={links.withFeedback!}
          >
            Feedback submitted
            {resolvedData ? (
              <div className="count">
                {counts.withFeedback.toLocaleString()}
              </div>
            ) : null}
          </StatusTabLink>
          <StatusTabLink<AutomationStatus>
            status="admin"
            currentStatus={selectedTab}
            href={links.admin!}
          >
            Admin
            {resolvedData ? (
              <div className="count">{counts.admin.toLocaleString()}</div>
            ) : null}
          </StatusTabLink>
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
            status={'success'}
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
              filter={criteria || ''}
              placeholder="Filter by exercise (min 3 chars)"
            />
            <Sorter
              className="automation-sorter"
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
            page={page}
            setPage={setPage}
            resolvedData={resolvedData}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
