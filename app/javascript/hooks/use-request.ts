import { fetchJSON } from '../utils/fetch-json'

export type APIError = {
  type: string
  message: string
}

export function useRequest(
  endpoint: string,
  body: any,
  method: string
): [Promise<void | object[]>, AbortController] {
  const cancel = new AbortController()
  const request = fetchJSON(endpoint, {
    method: method,
    signal: cancel.signal,
    body: body,
  }).catch((err) => {
    if (err instanceof Error && err.name === 'AbortError') {
      return
    }

    throw err
  })

  return [request, cancel]
}
