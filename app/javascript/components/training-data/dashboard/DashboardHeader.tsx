import React from 'react'
import { TextFilter } from '@/components/mentoring/TextFilter'
import { TrackFilter } from '@/components/mentoring/inbox/TrackFilter'
import { DashboardHeaderProps } from './Dashboard.types'

export function DashboardHeader({
  tracksRequest,
  request,
  setTrack,
  criteria,
  setCriteria,
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
    </header>
  )
}
