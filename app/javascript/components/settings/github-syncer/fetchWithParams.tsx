import toast from 'react-hot-toast'

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
    body: params
      ? JSON.stringify({
          github_solution_syncer: params,
        })
      : null,
  })
}

export async function handleJsonErrorResponse(
  response: Response,
  fallbackMessage: string
) {
  const text = await response.text()

  try {
    const data = JSON.parse(text)
    const message = data?.error?.message || fallbackMessage
    toast.error(message)
  } catch {
    console.error('Expected JSON, but received:', text)
    toast.error(fallbackMessage)
  }
}
