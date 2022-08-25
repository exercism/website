import React from 'react'
import { Pagination, Loading, GraphicalIcon } from '../../common'
import { Discussion } from './Discussion'
import { APIResponse } from '../Inbox'
import { QueryStatus } from 'react-query'
import { RefetchOptions } from 'react-query/types/core/query'

type Links = {
  queue: string
}

export const DiscussionList = ({
  resolvedData,
  latestData,
  refetch,
  status,
  setPage,
  links,
}: {
  resolvedData: APIResponse | undefined
  latestData: APIResponse | undefined
  status: QueryStatus
  setPage: (page: number) => void
  refetch: (options?: RefetchOptions) => Promise<APIResponse | undefined>
  links: Links
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
                    disabled={latestData === undefined}
                    current={resolvedData.meta.currentPage}
                    total={resolvedData.meta.totalPages}
                    setPage={setPage}
                  />
                </footer>
              </React.Fragment>
            )}
          </div>
        ))}
    </div>
  )
}
