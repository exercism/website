import {
  PaginatedQueryConfig,
  PaginatedQueryResult,
  QueryConfig,
  QueryKey,
  QueryResult,
  usePaginatedQuery,
  useQuery,
} from 'react-query'
import { camelizeKeys, decamelizeKeys } from 'humps'
import { sendRequest } from '../utils/send-request'
import { stringify } from 'qs'

export type Request<Query = Record<string, any>> = {
  endpoint: string | undefined
  query?: Query
  options: QueryConfig<any>
}

type PaginatedRequest = {
  endpoint: string | undefined
  query?: Record<string, any>
  options: PaginatedQueryConfig<any>
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

    const fetchWithCancel = fetch as any
    fetchWithCancel.cancel = cancel

    return fetch
  }
}

export function usePaginatedRequestQuery<TResult = unknown, TError = unknown>(
  key: QueryKey,
  request: PaginatedRequest
): PaginatedQueryResult<TResult, TError> {
  return usePaginatedQuery<TResult, TError>(key, handleFetch(request), {
    refetchOnWindowFocus: false,
    staleTime: 1000 * 30,
    ...camelizeKeys(request.options),
  })
}

export function useRequestQuery<TResult = unknown, TError = unknown>(
  key: QueryKey,
  request: Request
): QueryResult<TResult, TError> {
  return useQuery<TResult, TError>(key, handleFetch(request), {
    refetchOnWindowFocus: false,
    staleTime: 1000 * 30,
    ...camelizeKeys(request.options),
  })
}
