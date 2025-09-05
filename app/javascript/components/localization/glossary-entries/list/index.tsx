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
const CACHE_KEY = 'localization-originals-list'
export default function GlossaryEntriesList({
  originals,
  links,
  request: originalsRequest,
}: GlossaryEntriesListProps) {
  const { request, setCriteria, setPage, setQuery } = useList(originalsRequest)
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
        originals,
        request,
        setQuery,
        resolvedData,
        links,
        setCriteria,
        setPage,
        isFetching: true,
        status,
        error,
      }}
    >
      <Table />
    </GlossaryEntriesListContext.Provider>
  )
}
