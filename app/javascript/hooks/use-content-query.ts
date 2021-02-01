import { useQuery } from 'react-query'

function fetchContent(endpoint: string, signal: AbortSignal) {
  return fetch(endpoint, {
    method: 'get',
    signal,
  }).then((res) => {
    if (![200, 304].includes(res.status)) {
      return Promise.reject(
        `No content available. HTTP response status ${res.status}`
      )
    }

    return res.text()
  })
}

// Create a fetch request for the tooltip content, assign the abort controller to the promise
// https://react-query.tanstack.com/docs/guides/query-cancellation#using-fetch
function query(endpoint: string) {
  return () => {
    const controller = new AbortController()
    const signal = controller.signal
    return Object.assign(fetchContent(endpoint, signal), {
      cancel: () => controller.abort(),
    })
  }
}

export function useContentQuery(
  id: string,
  endpoint: string,
  enabled: boolean
): {
  isLoading: boolean
  isError: boolean
  htmlContent: string | undefined
} {
  const { isLoading, isError, data: htmlContent } = useQuery<string>(
    id,
    query(endpoint),
    { enabled }
  )

  return { isLoading, isError, htmlContent }
}
