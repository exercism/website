import React from 'react'
import { DiscussionList } from './inbox/DiscussionList'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { TrackFilter } from './inbox/TrackFilter'
import { useList } from '../../hooks/use-list'

export function Inbox({ tracksRequest, sortOptions, ...props }) {
  const {
    request: discussionsRequest,
    setCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(props.discussionsRequest)

  const setTrack = (track) => {
    setQuery({ track: track, page: 1 })
  }

  return (
    <div className="c-mentor-inbox">
      <header className="c-search-bar">
        <TrackFilter
          request={tracksRequest}
          value={discussionsRequest.query.track || null}
          setTrack={setTrack}
        />
        <TextFilter
          filter={discussionsRequest.query.criteria}
          setFilter={setCriteria}
          id="discussion-filter"
          placeholder="Filter by student or exercise name"
        />
        <Sorter
          sortOptions={sortOptions}
          order={discussionsRequest.query.order}
          setOrder={setOrder}
          id="discussion-sorter-sort"
        />
      </header>
      <DiscussionList request={discussionsRequest} setPage={setPage} />
    </div>
  )
}
