import React from 'react'
import { DiscussionList } from './inbox/DiscussionList'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { TrackFilter } from './inbox/TrackFilter'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'

export function Inbox({ tracksRequest, sortOptions, ...props }) {
  const { request, setCriteria, setOrder, setPage, setQuery } = useList(
    props.discussionsRequest
  )
  const isMountedRef = useIsMounted()
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    refetch,
  } = usePaginatedRequestQuery(
    ['mentor-discussion-list', request.endpoint, request.query],
    request,
    isMountedRef
  )

  const setTrack = (track) => {
    setQuery({ track: track, page: 1 })
  }

  return (
    <div className="c-mentor-inbox">
      <header className="c-search-bar">
        <TrackFilter
          request={tracksRequest}
          value={request.query.track || null}
          setTrack={setTrack}
        />
        <TextFilter
          filter={request.query.criteria}
          setFilter={setCriteria}
          id="discussion-filter"
          placeholder="Filter by student or exercise name"
        />
        {isFetching ? <span>Fetching...</span> : null}
        <Sorter
          sortOptions={sortOptions}
          order={request.query.order}
          setOrder={setOrder}
          id="discussion-sorter-sort"
        />
      </header>
      <DiscussionList
        latestData={latestData}
        resolvedData={resolvedData}
        status={status}
        refetch={refetch}
        request={request}
        setPage={setPage}
      />
    </div>
  )
}
