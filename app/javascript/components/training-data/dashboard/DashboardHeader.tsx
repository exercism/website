import React from 'react'
import { TextFilter } from '@/components/mentoring/TextFilter'
import { DashboardHeaderProps } from './Dashboard.types'
import { TrackList } from '@/components/mentoring/inbox/TrackList'

export function DashboardHeader({
  tracks,
  request,
  setTrack,
  criteria,
  setCriteria,
}: DashboardHeaderProps) {
  return (
    <header className="c-search-bar inbox-header">
      <div className="c-track-filter">
        <TrackList
          tracks={tracks}
          setTrack={setTrack}
          value={request.query.trackSlug || null}
        />
      </div>
      <TextFilter
        filter={criteria}
        setFilter={setCriteria}
        id="discussion-filter"
        placeholder="Filter exercise name"
      />
    </header>
  )
}
