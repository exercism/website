export function fetchWithParams({
  url,
  params,
  method = 'GET',
}: {
  url: string
  params?: Record<string, string | number | boolean>
  method?: 'GET' | 'DELETE'
}): Promise<Response> {
  const query = params
    ? '?' +
      new URLSearchParams(
        Object.entries(params).reduce((acc, [key, val]) => {
          acc[key] = String(val)
          return acc
        }, {} as Record<string, string>)
      ).toString()
    : ''

  return fetch(url + query, { method })
}
