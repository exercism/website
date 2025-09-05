import React, { useState, useEffect } from 'react'
import { DiscussionList } from './inbox/DiscussionList'
import { StatusTab } from './inbox/StatusTab'
import { TextFilter } from './TextFilter'
import { Sorter } from './Sorter'
import { TrackFilter } from './inbox/TrackFilter'
import {
  usePaginatedRequestQuery,
  type Request as BaseRequest,
} from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { ResultsZone } from '../ResultsZone'
import { MentorDiscussion, DiscussionStatus } from '../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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

export type Request = BaseRequest<{
  status: DiscussionStatus
  order?: string
  criteria?: string
  page?: number
  trackSlug?: string
}>

type Links = {
  queue: string
}

export default function Inbox({
  tracksRequest,
  sortOptions,
  discussionsRequest,
  links,
}: {
  tracksRequest: Request
  discussionsRequest: Request
  sortOptions: readonly SortOption[]
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation()
  const [criteria, setCriteria] = useState(discussionsRequest.query?.criteria)
  const {
    request,
    setCriteria: setRequestCriteria,
    setOrder,
    setPage,
    setQuery,
  } = useList(discussionsRequest)
  const {
    status,
    data: resolvedData,
    isFetching,
    refetch,
  } = usePaginatedRequestQuery<APIResponse>(
    ['mentor-discussion-list', request.endpoint, request.query],
    request
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria === undefined || criteria === null) return
      setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  const setTrack = (trackSlug: string | null) => {
    setQuery({ ...request.query, trackSlug: trackSlug, page: undefined })
  }

  const setStatus = (status: string) => {
    setQuery({ ...request.query, status: status, page: undefined })
  }

  return (
    <div className="c-mentor-inbox">
      <div className="tabs">
        <StatusTab<DiscussionStatus>
          status="awaiting_mentor"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          {t('inbox.inbox')}
          {resolvedData ? (
            <div className="count">{resolvedData.meta.awaitingMentorTotal}</div>
          ) : null}
        </StatusTab>
        <StatusTab<DiscussionStatus>
          status="awaiting_student"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          {t('inbox.awaitingStudent')}
          {resolvedData ? (
            <div className="count">
              {resolvedData.meta.awaitingStudentTotal}
            </div>
          ) : null}
        </StatusTab>
        <StatusTab<DiscussionStatus>
          status="finished"
          currentStatus={request.query.status}
          setStatus={setStatus}
        >
          {t('inbox.finished')}
          {resolvedData ? (
            <div className="count">{resolvedData.meta.finishedTotal}</div>
          ) : null}
        </StatusTab>
      </div>
      <div className="container">
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
            placeholder={t('inbox.filterByStudentOrExerciseName')}
          />
          <Sorter
            sortOptions={sortOptions}
            order={request.query.order}
            setOrder={setOrder}
            setPage={setPage}
          />
        </header>
        <ResultsZone isFetching={isFetching}>
          <DiscussionList
            resolvedData={resolvedData}
            status={status}
            refetch={refetch}
            setPage={setPage}
            links={links}
          />
        </ResultsZone>
      </div>
    </div>
  )
}
