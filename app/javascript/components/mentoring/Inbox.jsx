import React, { useState, useEffect, useRef } from 'react'
import { DiscussionList } from './inbox/DiscussionList'
import { StatusTab } from './inbox/StatusTab'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { TrackFilter } from './inbox/TrackFilter'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { ResultsZone } from '../ResultsZone'
import { useHistory } from '../../hooks/use-history'

export function Inbox({ tracksRequest, sortOptions, ...props }) {
  const [criteria, setCriteria] = useState('')
  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(props.discussionsRequest)
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

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 500)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: request.query })

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
          status="awaiting_mentor"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          Inbox
          {resolvedData ? (
            <div className="count">{resolvedData.meta.awaitingMentorTotal}</div>
          ) : null}
        </StatusTab>
        <StatusTab
          status="awaiting_student"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          Awaiting student
          {resolvedData ? (
            <div className="count">
              {resolvedData.meta.awaitingStudentTotal}
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
            filter={criteria}
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
        <ResultsZone isFetching={isFetching}>
          <DiscussionList
            latestData={latestData}
            resolvedData={resolvedData}
            status={status}
            refetch={refetch}
            request={request}
            setPage={setPage}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
