import React, { useState, useEffect } from 'react'
import { DiscussionList } from './inbox/DiscussionList'
import { StatusTab } from './inbox/StatusTab'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { TrackFilter } from './inbox/TrackFilter'
import { useList } from '../../hooks/use-list'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { ResultsZone } from '../ResultsZone'
import { useHistory, removeEmpty } from '../../hooks/use-history'
import { MentorDiscussion } from '../types'

export type SortOption = {
  value: string
  label: string
}

export type APIResponse = {
  results: readonly MentorDiscussion[]
  meta: {
    currentPage: number
    totalPages: number
    awaitingMentorTotal: number
    awaitingStudentTotal: number
    finishedTotal: number
  }
}

export const Inbox = ({
  tracksRequest,
  sortOptions,
  discussionsRequest,
}: {
  tracksRequest: Request
  discussionsRequest: Request
  sortOptions: readonly SortOption[]
}): JSX.Element => {
  const [criteria, setCriteria] = useState(
    discussionsRequest.query?.criteria || ''
  )
  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(discussionsRequest)
  const isMountedRef = useIsMounted()
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    refetch,
  } = usePaginatedRequestQuery<APIResponse>(
    ['mentor-discussion-list', request.endpoint, request.query],
    request,
    isMountedRef
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const setTrack = (track: string | null) => {
    setQuery({ ...request.query, track: track, page: undefined })
  }

  const setStatus = (status: string) => {
    setQuery({ ...request.query, status: status, page: undefined })
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
            request={{
              ...tracksRequest,
              query: { status: request.query.status },
            }}
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
          />
        </header>
        <ResultsZone isFetching={isFetching}>
          <DiscussionList
            latestData={latestData}
            resolvedData={resolvedData}
            status={status}
            refetch={refetch}
            setPage={setPage}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
