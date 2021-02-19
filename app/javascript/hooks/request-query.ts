import {
  PaginatedQueryConfig,
  PaginatedQueryResult,
  QueryConfig,
  QueryResult,
  usePaginatedQuery,
  useQuery,
} from 'react-query'
import { camelizeKeys, decamelizeKeys } from 'humps'
import { sendRequest } from '../utils/send-request'
import { stringify } from 'qs'

export type Request = {
  endpoint: string
  query?: Record<string, any>
  options: QueryConfig<any>
}

type PaginatedRequest = {
  endpoint: string
  query?: Record<string, any>
  options: PaginatedQueryConfig<any>
}

function handleFetch(
  request: Request,
  isMountedRef: React.MutableRefObject<boolean>
) {
  const params = request.query
    ? `?${stringify(decamelizeKeys(request.query), {
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
  key: string,
  request: PaginatedRequest,
  isMountedRef: React.MutableRefObject<boolean>
): PaginatedQueryResult<TResult, TError> {
  return usePaginatedQuery<TResult, TError>(
    [key, request.endpoint, request.query],
    () => {
      return handleFetch(request, isMountedRef)
    },
    camelizeKeys(request.options)
  )
}

export function useRequestQuery<TResult = unknown, TError = unknown>(
  key: string,
  request: Request,
  isMountedRef: React.MutableRefObject<boolean>
): QueryResult<TResult, TError> {
  return useQuery<TResult, TError>(
    key,
    () => {
      return handleFetch(request, isMountedRef)
    },
    camelizeKeys(request.options)
  )
}
