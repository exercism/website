import React from 'react'
import { Pagination } from '../../common/Pagination'
import { Discussion } from './Discussion'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'
import { useIsMounted } from 'use-is-mounted'

export function DiscussionList({ request, setPage }) {
  const isMountedRef = useIsMounted()
  const {
    isLoading,
    isError,
    isSuccess,
    resolvedData,
    latestData,
    refetch,
  } = usePaginatedRequestQuery('mentor-discussion-list', request, isMountedRef)

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
            <Discussion key={key} {...conversation} />
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
