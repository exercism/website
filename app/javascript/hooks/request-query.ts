import {
  useQuery,
  type QueryKey,
  type UseQueryResult,
  type UseQueryOptions,
} from '@tanstack/react-query'
import { camelizeKeys, decamelizeKeys } from 'humps'
import { sendRequest } from '../utils/send-request'
import { stringify } from 'qs'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type Request<Query = Record<string, any>> = {
  endpoint: string | undefined
  query?: Query
  options: UseQueryOptions
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
  return useQuery<TResult, TError>({
    queryKey: key,
    queryFn: handleFetch(request),
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    keepPreviousData: true,
    ...camelizeKeys(request.options),
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
