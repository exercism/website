import React from 'react'
import { QueryStatus, UseQueryResult } from '@tanstack/react-query'
import { Pagination, Loading, GraphicalIcon } from '@/components/common'
import { Discussion } from './Discussion'
import type { APIResponse } from '../Inbox'
import { scrollToTop } from '@/utils/scroll-to-top'

type Links = {
  queue: string
}

export const DiscussionList = ({
  resolvedData,
  refetch,
  status,
  setPage,
  links,
}: {
  resolvedData: APIResponse | undefined
  status: QueryStatus
  setPage: (page: number) => void
  links: Links
  refetch: () => Promise<UseQueryResult<APIResponse, unknown>>
}): JSX.Element => {
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
        (resolvedData && resolvedData.results.length === 0 ? (
          <>
            <div className="--no-results">
              <GraphicalIcon icon="mentoring" category="graphics" />
              <h3>No mentoring discussions</h3>
              <a href={links.queue} className="btn-simple">
                Mentor a new solution
              </a>
            </div>
          </>
        ) : (
          <div className="--conversations">
            {resolvedData && (
              <React.Fragment>
                {resolvedData.results.map((discussion, key) => (
                  <Discussion key={key} discussion={discussion} />
                ))}
                <footer>
                  <Pagination
                    disabled={resolvedData === undefined}
                    current={resolvedData.meta.currentPage}
                    total={resolvedData.meta.totalPages}
                    setPage={(p) => {
                      setPage(p)
                      scrollToTop()
                    }}
                  />
                </footer>
              </React.Fragment>
            )}
          </div>
        ))}
    </div>
  )
}
