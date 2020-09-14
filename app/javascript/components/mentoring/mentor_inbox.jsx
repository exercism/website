import React, { useReducer } from 'react'
import { ConversationList } from './mentor_inbox/conversation_list'
import { TrackFilter } from './mentor_inbox/track_filter'

export function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    case 'track.changed':
      return {
        ...state,
        query: { ...state.query, track: action.payload.track, page: 1 },
      }
  }
}

export function MentorInbox({ tracksRequest, ...props }) {
  const [conversationsRequest, dispatch] = useReducer(
    reducer,
    props.conversationsRequest
  )

  function setPage(page) {
    dispatch({ type: 'page.changed', payload: { page: page } })
  }

  function setTrack(track) {
    dispatch({ type: 'track.changed', payload: { track: track } })
  }

  return (
    <div>
      <TrackFilter request={tracksRequest} setTrack={setTrack} />
      <ConversationList request={conversationsRequest} setPage={setPage} />
    </div>
  )
}
