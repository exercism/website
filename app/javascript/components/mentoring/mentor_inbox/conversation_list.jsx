import React from 'react'
import { usePaginatedQuery } from 'react-query'
import { Pagination } from './conversation_list/pagination'
import { Conversation } from './conversation_list/conversation'
import { UrlParams } from '../../../utils/url_params'

async function fetchConversations(key, url, query) {
  const resp = await fetch(`${url}?${new UrlParams(query).toString()}`)

  return resp.json()
}

export function ConversationList({ endpoint, query, setPage, retryParams }) {
  const { status, resolvedData, latestData } = usePaginatedQuery(
    ['mentor-conversations-list', endpoint, query],
    fetchConversations,
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
                <Conversation key={key} {...conversation} />
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
