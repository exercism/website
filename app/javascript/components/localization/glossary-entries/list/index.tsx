/// <reference path="../types.d.ts" />
import React, { createContext } from 'react'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { useList } from '@/hooks/use-list'
import { removeEmpty, useHistory } from '@/hooks/use-history'
import { Table } from './Table'
import { useLogger } from '@/hooks'

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

  useLogger('data', glossaryEntries)

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
      }}
    >
      <Table />
    </GlossaryEntriesListContext.Provider>
  )
}
