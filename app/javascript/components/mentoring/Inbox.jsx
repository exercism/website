import React from 'react'
import { DiscussionList } from './inbox/DiscussionList'
import { StatusTab } from './inbox/StatusTab'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { TrackFilter } from './inbox/TrackFilter'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { FetchingOverlay } from '../FetchingOverlay'

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
    setQuery({ ...request.query, track: track, page: 1 })
  }

  const setStatus = (status) => {
    setQuery({ ...request.query, status: status, page: 1 })
  }

  return (
    <div className="c-mentor-inbox">
      <div className="tabs">
        <StatusTab
          status="requires_mentor_action"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          Inbox
          {resolvedData ? (
            <div className="count">
              {resolvedData.meta.requiresMentorActionTotal}
            </div>
          ) : null}
        </StatusTab>
        <StatusTab
          status="requires_student_action"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          Awaiting student
          {resolvedData ? (
            <div className="count">
              {resolvedData.meta.requiresStudentActionTotal}
            </div>
          ) : null}
        </StatusTab>
        <StatusTab
          status="finished"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          Finished
          {resolvedData ? (
            <div className="count">{resolvedData.meta.finishedTotal}</div>
          ) : null}
        </StatusTab>
      </div>
      <div className="container">
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
          <Sorter
            sortOptions={sortOptions}
            order={request.query.order}
            setOrder={setOrder}
            id="discussion-sorter-sort"
          />
        </header>
        <FetchingOverlay isFetching={isFetching}>
          <DiscussionList
            latestData={latestData}
            resolvedData={resolvedData}
            status={status}
            refetch={refetch}
            request={request}
            setPage={setPage}
          />
        </FetchingOverlay>
      </div>
    </div>
  )
}
