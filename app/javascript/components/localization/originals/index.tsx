/// <reference path="./types.d.ts" />
import React, { createContext } from 'react'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { useList } from '@/hooks/use-list'
import { removeEmpty, useHistory } from '@/hooks/use-history'
import { Table } from './Table'

export const OriginalsListContext = createContext<OriginalsListContextType>(
  {} as OriginalsListContextType
)
const CACHE_KEY = 'localization-originals-list'
export default function OriginalsList({
  originals,
  links,
  request: originalsRequest,
}: OriginalsListProps) {
  const { request, setCriteria, setPage, setQuery } = useList(originalsRequest)
  const {
    status,
    error,
    data: resolvedData,
  } = usePaginatedRequestQuery<OriginalsListData>([CACHE_KEY, request], request)

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <OriginalsListContext.Provider
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
    </OriginalsListContext.Provider>
  )
}
