import React from 'react'
import { Pagination } from '../../common/Pagination'
import { Conversation } from './Conversation'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'
import { useIsMounted } from 'use-is-mounted'

export function ConversationList({ request, setPage }) {
  const isMountedRef = useIsMounted()
  const {
    isLoading,
    isError,
    isSuccess,
    resolvedData,
    latestData,
    refetch,
  } = usePaginatedRequestQuery(
    'mentor-conversations-list',
    request,
    isMountedRef
  )

  return (
    <div>
      {isLoading && <Loading />}
      {isError && (
        <>
          <p>Something went wrong</p>
          <button onClick={() => refetch()} aria-label="Retry">
            Retry
          </button>
        </>
      )}
      {isSuccess && (
        <div className="--conversations">
          {resolvedData.results.map((conversation, key) => (
            <Conversation key={key} {...conversation} />
          ))}
          {latestData && (
            <footer>
              <Pagination
                current={request.query.currentPage}
                total={latestData.meta.totalPages}
                setPage={setPage}
              />
            </footer>
          )}
        </div>
      )}
    </div>
  )
}
