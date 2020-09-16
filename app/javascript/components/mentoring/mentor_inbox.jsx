import React, { useReducer, useCallback } from 'react'
import { ConversationList } from './mentor_inbox/conversation_list'
import { ConversationFilter } from './mentor_inbox/conversation_filter'
import { ConversationSorter } from './mentor_inbox/conversation_sorter'
import { TrackFilter } from './mentor_inbox/track_filter'

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
        throw 'Unknown action type'
      }
      return state
  }
}

export function MentorInbox({ tracksRequest, ...props }) {
  const [conversationsRequest, dispatch] = useReducer(
    reducer,
    Object.assign({ query: { page: 1 } }, props.conversationsRequest)
  )

  const setPage = useCallback(
    (page) => {
      dispatch({ type: 'page.changed', payload: { page: page } })
    },
    [dispatch]
  )

  const setTrack = useCallback(
    (track) => {
      dispatch({ type: 'track.changed', payload: { track: track } })
    },
    [dispatch]
  )

  function setSort(sort) {
    dispatch({ type: 'sort.changed', payload: { sort: sort } })
  }

  function setFilter(filter) {
    dispatch({ type: 'filter.changed', payload: { filter: filter } })
  }

  return (
    <div>
      <TrackFilter request={tracksRequest} setTrack={setTrack} />
      <ConversationFilter
        filter={conversationsRequest.query.filter}
        setFilter={setFilter}
      />
      <ConversationSorter
        sort={conversationsRequest.query.sort}
        setSort={setSort}
      />
      <ConversationList request={conversationsRequest} setPage={setPage} />
    </div>
  )
}
