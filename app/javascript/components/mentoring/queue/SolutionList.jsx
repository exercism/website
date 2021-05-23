import React, { useState } from 'react'
import { Solution } from './Solution'
import { Pagination } from '../../common/Pagination'
import { FetchingBoundary } from '../../FetchingBoundary'

const DEFAULT_ERROR = new Error('Unable to fetch queue')

export const SolutionList = ({ status, error, ...props }) => {
  return (
    <FetchingBoundary
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    >
      <Component {...props} />
    </FetchingBoundary>
  )
}

function Component({ resolvedData, latestData, page, setPage }) {
  return (
    <>
      {resolvedData.results.length > 0 ? (
        <>
          <div className="--solutions">
            {resolvedData.results.length > 0
              ? resolvedData.results.map((solution, key) => (
                  <Solution
                    key={key}
                    {...solution}
                  />
                ))
              : 'No discussions found'}
          </div>
          <footer>
            <Pagination
              disabled={latestData === undefined}
              current={page}
              total={resolvedData.meta.totalPages}
              setPage={setPage}
            />
          </footer>
        </>
      ) : null}
    </>
  )
}
