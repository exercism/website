import {
  useQuery,
  type QueryKey,
  type UseQueryResult,
  type UseQueryOptions,
  keepPreviousData,
} from '@tanstack/react-query'
import { useRef } from 'react'
import isEqual from 'lodash.isequal'
import { camelizeKeys, decamelizeKeys } from 'humps'
import { sendRequest } from '../utils/send-request'
import { stringify } from 'qs'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type Request<Query = Record<string, any>> = {
  endpoint: string | undefined
  query?: Query
  options: Omit<UseQueryOptions, 'queryKey' | 'queryFn'>
}

function handleFetch(request: Request) {
  const delimiter =
    request.endpoint && request.endpoint.includes('?') ? '&' : '?'
  const params = request.query
    ? `${delimiter}${stringify(decamelizeKeys(request.query), {
        arrayFormat: 'brackets',
      })}`
    : ''

  return () => {
    const { fetch, cancel } = sendRequest({
      endpoint: `${request.endpoint}${params}`,
      body: null,
      method: 'GET',
    })

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const fetchWithCancel = fetch as any
    fetchWithCancel.cancel = cancel

    return fetch
  }
}

export function usePaginatedRequestQuery<TResult = unknown, TError = unknown>(
  key: QueryKey,
  request: Request
): UseQueryResult<TResult, TError> {
  const { query = {}, options = {} } = request

  // we are storing the initial query on mount to detect when it changes.
  const initialQueryRef = useRef(query)
  // if the query changes (e.g. due to search or pagination), we omit initialData
  // so tanstack query doesn't briefly show outdated initial data during the transition,
  // and previously fetched data can take over.
  // this avoids visual flashes where irrelevant initial data appears before new data loads.
  const queryChanged = !isEqual(initialQueryRef.current, query)
  const initialData = queryChanged ? undefined : options?.initialData

  return useQuery<TResult, TError>({
    queryKey: key,
    queryFn: handleFetch(request),
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    placeholderData: keepPreviousData,
    ...camelizeKeys(options),
    initialData: initialData as TResult | undefined,
  })
}

export function useRequestQuery<TResult = unknown, TError = unknown>(
  key: QueryKey,
  request: Request
): UseQueryResult<TResult, TError> {
  return useQuery<TResult, TError>({
    queryKey: key,
    queryFn: handleFetch(request),
    refetchOnWindowFocus: false,
    staleTime: 1000 * 30,
    ...camelizeKeys(request.options),
  })
}
