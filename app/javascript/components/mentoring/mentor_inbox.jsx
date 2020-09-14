import React, { useReducer } from 'react'
import { ConversationList } from './mentor_inbox/conversation_list'
import { TrackFilter } from './mentor_inbox/track_filter'

export function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, page: action.payload.page }
    case 'track.changed':
      return { ...state, track: action.payload.track, page: 1 }
  }
}

export function MentorInbox({
  conversationsEndpoint,
  tracksEndpoint,
  retryParams,
  ...props
}) {
  const [query, dispatch] = useReducer(
    reducer,
    Object.assign({ page: 1 }, props.query)
  )

  function setPage(page) {
    dispatch({ type: 'page.changed', payload: { page: page } })
  }

  function setTrack(track) {
    dispatch({ type: 'track.changed', payload: { track: track } })
  }

  return (
    <div>
      <TrackFilter endpoint={tracksEndpoint} setTrack={setTrack} />
      <ConversationList
        endpoint={conversationsEndpoint}
        query={query}
        setPage={setPage}
        retryParams={retryParams}
      />
    </div>
  )
}
