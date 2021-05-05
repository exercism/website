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

export type Request = {
  endpoint: string | undefined
  query?: Record<string, any>
  options: QueryConfig<any>
}

type PaginatedRequest = {
  endpoint: string | undefined
  query?: Record<string, any>
  options: PaginatedQueryConfig<any>
}

function handleFetch(
  request: Request,
  isMountedRef: React.MutableRefObject<boolean>
) {
  const delimiter =
    request.endpoint && request.endpoint.includes('?') ? '&' : '?'
  const params = request.query
    ? `${delimiter}${stringify(decamelizeKeys(request.query), {
        arrayFormat: 'brackets',
      })}`
    : ''

  return sendRequest({
    endpoint: `${request.endpoint}${params}`,
    body: null,
    method: 'GET',
    isMountedRef: isMountedRef,
  })
}

export function usePaginatedRequestQuery<TResult = unknown, TError = unknown>(
  key: QueryKey,
  request: PaginatedRequest,
  isMountedRef: React.MutableRefObject<boolean>
): PaginatedQueryResult<TResult, TError> {
  return usePaginatedQuery<TResult, TError>(
    key,
    () => {
      return handleFetch(request, isMountedRef)
    },
    { refetchOnWindowFocus: false, ...camelizeKeys(request.options) }
  )
}

export function useRequestQuery<TResult = unknown, TError = unknown>(
  key: QueryKey,
  request: Request,
  isMountedRef: React.MutableRefObject<boolean>
): QueryResult<TResult, TError> {
  return useQuery<TResult, TError>(
    key,
    () => {
      return handleFetch(request, isMountedRef)
    },
    { refetchOnWindowFocus: false, ...camelizeKeys(request.options) }
  )
}
