import React from 'react'
import { Pagination } from '../Pagination'
import { Conversation } from './Conversation'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'

export function ConversationList({ request, setPage }) {
  const {
    isSuccess,
    isError,
    isFetching,
    resolvedData,
    latestData,
    refetch,
  } = usePaginatedRequestQuery('mentor-conversations-list', request)

  return (
    <div className="conversations-list">
      {isFetching && <Loading />}
      {isError && (
        <>
          <p>Something went wrong</p>
          <button onClick={() => refetch()} aria-label="Retry">
            Retry
          </button>
        </>
      )}
      {isSuccess && (
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
              current={request.query.page}
              total={latestData.meta.total}
              setPage={setPage}
            />
          )}
        </>
      )}
    </div>
  )
}
