import React, { useState } from 'react'
import { ConversationList } from './mentor_inbox/conversation_list'
import { TrackFilter } from './mentor_inbox/track_filter'

export function MentorInbox({
  conversationsEndpoint,
  tracksEndpoint,
  retryParams,
  ...props
}) {
  const [query, setQuery] = useState(Object.assign({ page: 1 }, props.query))

  function setPage(page) {
    setQuery({ ...query, page: page })
  }

  function setTrack(track) {
    setQuery({ ...query, track: track })
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
