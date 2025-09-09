import React from 'react'
import { FilterFallback, Pagination } from '@/components/common'
import { GlossaryEntriesListContext } from '.'
import { GlossaryEntriesTableListElement } from './GlossaryEntriesTableListElement'
import { FetchingBoundary } from '@/components/FetchingBoundary'

export function GlossaryEntriesTableList() {
  const { setPage, resolvedData, request, error, status } = React.useContext(
    GlossaryEntriesListContext
  )

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
          resolvedData.results.map((glossaryEntry, key) => (
            <GlossaryEntriesTableListElement
              glossaryEntry={glossaryEntry}
              key={key}
            />
          ))
        ) : (
          <FilterFallback
            icon="no-result-magnifier"
            title="No glossary entries found"
            description="Try changing your filters to find glossary entries that need checking."
          />
        )}
      </div>
      <footer>
        <Pagination
          current={request.query.page || 1}
          total={resolvedData?.meta.totalPages || 1}
          setPage={setPage}
        />
      </footer>
    </FetchingBoundary>
  )
}
