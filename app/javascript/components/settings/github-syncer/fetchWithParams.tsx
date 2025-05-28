export function fetchWithParams({
  url,
  params,
  method = 'PATCH',
}: {
  url: string
  params?: Record<string, string | number | boolean>
  method?: 'DELETE' | 'PATCH'
}): Promise<Response> {
  return fetch(url, {
    method,
    headers: {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify({
      github_solution_syncer: params,
    }),
  })
}
