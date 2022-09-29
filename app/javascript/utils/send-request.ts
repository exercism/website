import { fetchJSON } from './fetch-json'

export type APIError = {
  type: string
  message: string
}

export const sendRequest = <T extends any = any>({
  endpoint,
  body,
  method,
}: {
  endpoint: string
  body: string | null | FormData
  method: string
}): { fetch: Promise<T>; cancel: () => void } => {
  const cancel = new AbortController()

  if (!endpoint) {
    return { fetch: Promise.reject(), cancel: cancel.abort }
  }

  const fetch = fetchJSON<T>(endpoint, {
    method: method,
    signal: cancel.signal,
    body: body,
  })

  return { fetch, cancel: cancel.abort }
}
