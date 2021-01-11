import {
  PaginatedQueryConfig,
  QueryConfig,
  usePaginatedQuery,
  useQuery,
} from 'react-query'
import { UrlParams } from '../utils/url-params'
import { camelizeKeys } from 'humps'

type RequestQuery = ConstructorParameters<typeof UrlParams>[0]

type Request = {
  endpoint: string
  query?: RequestQuery
  options: QueryConfig<any>
}

type PaginatedRequest = {
  endpoint: string
  query?: RequestQuery
  options: PaginatedQueryConfig<any>
}

function handleFetch<TResult>(key: string, url: string, query: RequestQuery) {
  return fetch(`${url}?${new UrlParams(query).toString()}`)
    .then((response) => {
      if (!response.ok) {
        throw response
      }

      return response
    })
    .then((response) => response.json())
    .then((json) => (camelizeKeys(json) as unknown) as TResult)
}

export function usePaginatedRequestQuery<TResult = unknown, TError = unknown>(
  key: string,
  request: PaginatedRequest
) {
  return usePaginatedQuery<TResult, TError>(
    [key, request.endpoint, request.query],
    handleFetch,
    camelizeKeys(request.options)
  )
}

export function useRequestQuery<TResult = unknown, TError = unknown>(
  key: string,
  request: Request
) {
  return useQuery<TResult, TError>(
    [key, request.endpoint, request.query],
    handleFetch,
    camelizeKeys(request.options)
  )
}
