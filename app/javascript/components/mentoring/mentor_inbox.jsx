import React, { useReducer, useCallback } from 'react'
import { ConversationList } from './mentor_inbox/conversation_list'
import { TextFilter } from './text_filter'
import { Sorter } from './sorter'
import { TrackFilter } from './mentor_inbox/track_filter'
import { useList } from '../../hooks/use_list'

function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    case 'track.changed':
      return {
        ...state,
        query: { ...state.query, track: action.payload.track, page: 1 },
      }
    case 'sort.changed':
      return {
        ...state,
        query: { ...state.query, sort: action.payload.sort },
      }
    case 'filter.changed':
      return {
        ...state,
        query: { ...state.query, filter: action.payload.filter, page: 1 },
      }
    default:
      if (process.env.NODE_ENV === 'development') {
        throw new Error(`Unknown action type: ${action.type}`)
      }
      return state
  }
}

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
