import React, { useState } from 'react'
import { usePaginatedQuery } from 'react-query'
import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
import { Pagination } from './mentor_conversations_list/pagination'
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

async function fetchSolutions(key, url, params) {
  const resp = await fetch(url)

  return resp.json()
}

export function MentorConversationsList({ endpoint, ...props }) {
  const [page, setPage] = useState(1)
  const urlParams = new UrlParams(
    Object.assign({ page: page }, props.urlParams)
  )
  const retryParams = props.retryParams
  const { status, resolvedData, latestData } = usePaginatedQuery(
    ['mentor-conversations-list', `${endpoint}?${urlParams.toString()}`],
    fetchSolutions,
    retryParams
  )

  return (
    <div>
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
              current={page}
              total={latestData.meta.total}
              setPage={setPage}
            />
          )}
        </>
      )}
    </div>
  )
}
