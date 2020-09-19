import React, { useReducer, useCallback } from 'react'
import { ConversationList } from './mentor_inbox/conversation_list'
import { TextFilter } from './text_filter'
import { Sorter } from './sorter'
import { TrackFilter } from './mentor_inbox/track_filter'
import { useList } from '../../hooks/use_list'

export function MentorInbox({ tracksRequest, ...props }) {
  const [conversationsRequest, setFilter, setSort, setPage, addQuery] = useList(
    props.conversationsRequest
  )

  const setTrack = (track) => {
    addQuery({ track: track, page: 1 })
  }

  return (
    <div className="mentor-inbox">
      <TrackFilter request={tracksRequest} setTrack={setTrack} />
      <TextFilter
        filter={conversationsRequest.query.filter}
        setFilter={setFilter}
        id="conversation-filter"
        placeholder="Filter by student or exercism name"
      />
      <Sorter
        sort={conversationsRequest.query.sort}
        setSort={setSort}
        id="conversation-sorter-sort"
      />
      <ConversationList request={conversationsRequest} setPage={setPage} />
    </div>
  )
}
