import React from 'react'
import { Pagination, Loading, GraphicalIcon } from '../../common'
import { Discussion } from './Discussion'

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
      {status === 'success' &&
        (resolvedData.results.length === 0 ? (
          <>
            <div className="--no-results">
              <GraphicalIcon icon="mentoring" category="graphics" />
              <h3>No mentoring discussions</h3>
              {/* TODO: Drive this URL from the component */}
              <a href="/mentoring/queue" className="btn-simple">
                Mentor a new solution
              </a>
            </div>
          </>
        ) : (
          <div className="--conversations">
            {resolvedData.results.map((discussion, key) => (
              <Discussion key={key} discussion={discussion} />
            ))}
            <footer>
              <Pagination
                disabled={latestData === undefined}
                current={resolvedData.meta.currentPage}
                total={resolvedData.meta.totalPages}
                setPage={setPage}
              />
            </footer>
          </div>
        ))}
    </div>
  )
}
