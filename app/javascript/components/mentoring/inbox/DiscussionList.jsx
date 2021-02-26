import React from 'react'
import { Pagination } from '../../common/Pagination'
import { Discussion } from './Discussion'
import { Loading } from '../../common/Loading'

export function DiscussionList({
  resolvedData,
  latestData,
  request,
  refetch,
  status,
  setPage,
}) {
  return (
    <div>
      {status === 'loading' && <Loading />}
      {status === 'error' && (
        <>
          <p>Something went wrong</p>
          <button onClick={() => refetch()} aria-label="Retry">
            Retry
          </button>
        </>
      )}
      {status === 'success' && (
        <div className="--conversations">
          {resolvedData.results.map((conversation, key) => (
            <Discussion key={key} {...conversation} />
          ))}
          <footer>
            <Pagination
              disabled={latestData === undefined}
              current={request.query.currentPage}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </footer>
        </div>
      )}
    </div>
  )
}
