import { camelizeKeys } from 'humps'

export async function fetchJSON<T extends any>(
  input: RequestInfo,
  options: RequestInit
): Promise<T> {
  const headers = {
    'content-type': 'application/json',
    accept: 'application/json',
  }

  return fetch(input, Object.assign(options, { headers }))
    .then(async (response) => {
      const contentType = response.headers.get('Content-Type')
      if (
        !contentType ||
        (!contentType.includes('+json') &&
          !contentType.includes('application/json'))
      ) {
        throw response
      }

      if (!response.ok) throw response

      return response.json()
    })
    .then((json) => camelizeKeys(json) as T)
}
