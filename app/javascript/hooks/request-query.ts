import {
  PaginatedQueryConfig,
  PaginatedQueryResult,
  QueryConfig,
  QueryResult,
  usePaginatedQuery,
  useQuery,
} from 'react-query'
import { UrlParams } from '../utils/url-params'
import { camelizeKeys } from 'humps'
import { sendRequest } from '../utils/send-request'

type RequestQuery = ConstructorParameters<typeof UrlParams>[0]

export type Request = {
  endpoint: string
  query?: RequestQuery
  options: QueryConfig<any>
}

type PaginatedRequest = {
  endpoint: string
  query?: RequestQuery
  options: PaginatedQueryConfig<any>
}

function handleFetch(
  request: Request,
  isMountedRef: React.MutableRefObject<boolean>
) {
  return sendRequest({
    endpoint: `${request.endpoint}?${new UrlParams(request.query).toString()}`,
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
    [key, request.endpoint, request.query],
    () => {
      return handleFetch(request, isMountedRef)
    },
    camelizeKeys(request.options)
  )
}
