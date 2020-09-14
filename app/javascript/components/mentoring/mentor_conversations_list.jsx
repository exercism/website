import React, { useState } from 'react'
import { usePaginatedQuery } from 'react-query'
import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import { Pagination } from './mentor_conversations_list/pagination'
import { TrackFilter } from './mentor_conversations_list/track_filter'
import { UrlParams } from '../../utils/url_params'
dayjs.extend(RelativeTime)

function MentorConversationListRow({
  trackTitle,
  trackIconUrl,
  menteeAvatarUrl,
  menteeHandle,
  exerciseTitle,
  isStarred,
  haveMentoredPreviously,
  isNewIteration,
  postsCount,
  updatedAt,
  url,
}) {
  return (
    <tr>
      <td>
        <img
          style={{ width: 100 }}
          src={trackIconUrl}
          alt={`icon indicating ${trackTitle}`}
        />
      </td>
      <td>
        <img
          style={{ width: 100 }}
          src={menteeAvatarUrl}
          alt={`avatar for ${menteeHandle}`}
        />
      </td>
      <td>{menteeHandle}</td>
      <td>{exerciseTitle}</td>
      <td>{isStarred.toString()}</td>
      <td>{haveMentoredPreviously.toString()}</td>
      <td>{isNewIteration.toString()}</td>
      <td>{postsCount}</td>
      <td>{dayjs(updatedAt).fromNow()}</td>
      <td>{url}</td>
    </tr>
  )
}

async function fetchConversations(key, url, query) {
  const resp = await fetch(`${url}?${new UrlParams(query).toString()}`)

  return resp.json()
}

export function MentorConversationsList({
  conversationsEndpoint,
  tracksEndpoint,
  ...props
}) {
  const [query, setQuery] = useState(Object.assign({ page: 1 }, props.query))
  const retryParams = props.retryParams
  const { status, resolvedData, latestData } = usePaginatedQuery(
    ['mentor-conversations-list', conversationsEndpoint, query],
    fetchConversations,
    retryParams
  )

  function setPage(page) {
    setQuery({ ...query, page: page })
  }

  function setTrack(track) {
    setQuery({ ...query, track: track })
  }

  return (
    <div>
      <TrackFilter endpoint={tracksEndpoint} setTrack={setTrack} />
      {status === 'loading' && <p>Loading</p>}
      {status === 'error' && <p>Something went wrong</p>}
      {status === 'success' && (
        <>
          <table>
            <thead>
              <tr>
                <th>Track icon</th>
                <th>Mentee avatar</th>
                <th>Mentee handle</th>
                <th>Exercise title</th>
                <th>Starred?</th>
                <th>Mentored previously?</th>
                <th>New iteration?</th>
                <th>Posts count</th>
                <th>Updated at</th>
                <th>URL</th>
              </tr>
            </thead>
            <tbody>
              {resolvedData.results.map((conversation, key) => (
                <MentorConversationListRow key={key} {...conversation} />
              ))}
            </tbody>
          </table>
          {latestData && (
            <Pagination
              current={query.page}
              total={latestData.meta.total}
              setPage={setPage}
            />
          )}
        </>
      )}
    </div>
  )
}
