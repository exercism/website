import React from 'react'
import { TextFilter } from '@/components/mentoring/TextFilter'
import { TrackFilter } from '@/components/mentoring/inbox/TrackFilter'
import { Sorter } from '@/components/mentoring/Sorter'
import { DashboardHeaderProps } from './Dashboard.types'

export function DashboardHeader({
  tracksRequest,
  request,
  setTrack,
  criteria,
  setCriteria,
  setOrder,
  setPage,
}: DashboardHeaderProps) {
  return (
    <header className="c-search-bar inbox-header">
      <TrackFilter
        request={{
          ...tracksRequest,
          query: { status: request.query.status },
        }}
        value={request.query.trackSlug || null}
        setTrack={setTrack}
      />
      <TextFilter
        filter={criteria}
        setFilter={setCriteria}
        id="discussion-filter"
        placeholder="Filter by student or exercise name"
      />
      {/* we may not need a sorter */}
      {/* <Sorter
        sortOptions={sortOptions}
        order={request.query.order}
        setOrder={setOrder}
        setPage={setPage}
      /> */}
    </header>
  )
}
