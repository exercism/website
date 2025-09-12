/// <reference path="../types.d.ts" />
import React, { createContext } from 'react'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { useList } from '@/hooks/use-list'
import { removeEmpty, useHistory } from '@/hooks/use-history'
import { Table } from './Table'

export const GlossaryEntriesListContext =
  createContext<GlossaryEntriesListContextType>(
    {} as GlossaryEntriesListContextType
  )
const CACHE_KEY = 'localization-glossary-entries-list'
export default function GlossaryEntriesList({
  glossaryEntries,
  translationLocales,
  links,
  request: glossaryEntriesRequest,
  mayCreateTranslationProposals,
  mayManageTranslationProposals,
}: GlossaryEntriesListProps) {
  const { request, setCriteria, setPage, setQuery } = useList(
    glossaryEntriesRequest
  )
  const {
    status,
    error,
    data: resolvedData,
  } = usePaginatedRequestQuery<GlossaryEntriesListData>(
    [CACHE_KEY, request],
    request
  )

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <GlossaryEntriesListContext.Provider
      value={{
        glossaryEntries,
        request,
        setQuery,
        resolvedData,
        links,
        setCriteria,
        setPage,
        isFetching: true,
        status,
        error,
        translationLocales,
        mayCreateTranslationProposals,
        mayManageTranslationProposals,
      }}
    >
      <Table />
    </GlossaryEntriesListContext.Provider>
  )
}
