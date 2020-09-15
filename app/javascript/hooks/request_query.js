import { usePaginatedQuery, useQuery } from 'react-query'
import { UrlParams } from '../utils/url_params'

async function handleFetch(key, url, query) {
  const resp = await fetch(`${url}?${new UrlParams(query).toString()}`)

  return resp.json()
}

export function usePaginatedRequestQuery(key, request) {
  return usePaginatedQuery(
    [key, request.endpoint, request.query],
    handleFetch,
    request.retry
  )
}

export function useRequestQuery(key, request, fetch) {
  return useQuery(
    [key, request.endpoint, request.query],
    handleFetch,
    request.retry
  )
}
