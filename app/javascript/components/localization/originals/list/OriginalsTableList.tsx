import React from 'react'
import { FilterFallback, Pagination } from '@/components/common'
import { OriginalsListContext } from '.'
import { OriginalsTableListElement } from './OriginalsTableListElement'
import { FetchingBoundary } from '@/components/FetchingBoundary'

export function OriginalsTableList() {
  const { setPage, resolvedData, request, error, status } =
    React.useContext(OriginalsListContext)

  return (
    <FetchingBoundary
      status={status}
      error={error}
      defaultError={
        new Error('An unexpected error occurred while loading originals.')
      }
    >
      <div>
        {resolvedData &&
        resolvedData.results &&
        resolvedData.results.length > 0 ? (
          resolvedData.results.map((original, key) => (
            <OriginalsTableListElement original={original} key={key} />
          ))
        ) : (
          <FilterFallback
            icon="no-result-magnifier"
            title="No translations found."
            description="Try changing your filters to find originals that need checking."
          />
        )}
      </div>
      <footer>
        <Pagination
          disabled={true}
          current={request.query.page || 1}
          total={resolvedData?.meta.totalPages || 1}
          setPage={setPage}
        />
      </footer>
    </FetchingBoundary>
  )
}
