import { fetchJSON } from './fetch-json'

export type APIError = {
  type: string
  message: string
}

export const sendPostRequest = ({
  endpoint,
  body,
  isMountedRef,
}: {
  endpoint: string
  body: any
  isMountedRef: React.MutableRefObject<Boolean>
}) => {
  return sendRequest({
    endpoint: endpoint,
    body: JSON.stringify(body),
    method: 'POST',
    isMountedRef: isMountedRef,
  })
}

export const sendRequest = ({
  endpoint,
  body,
  method,
  isMountedRef,
}: {
  endpoint: string
  body: any
  method: string
  isMountedRef: React.MutableRefObject<Boolean>
}) => {
  const cancel = new AbortController()

  return fetchJSON(endpoint, {
    method: method,
    signal: cancel.signal,
    body: body,
  })
    .then((json: any) => {
      if (!isMountedRef.current) {
        throw new Error('Component not mounted')
      }

      return json
    })
    .catch((err) => {
      if (!isMountedRef.current) {
        return
      }

      if (err.message === 'Component not mounted') {
        return
      }

      if (err instanceof Error && err.name === 'AbortError') {
        return
      }

      throw err
    })
}
