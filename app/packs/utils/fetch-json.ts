import { camelizeKeys } from 'humps'

export function fetchJSON(endpoint: string, options: any) {
  const headers = {
    'content-type': 'application/json',
    accept: 'application/json',
  }

  return fetch(endpoint, Object.assign(options, { headers: headers }))
    .then((response) => {
      if (!response.ok) {
        throw response
      }

      const contentType = response.headers.get('Content-Type')
      if (
        !contentType ||
        (!contentType.includes('+json') &&
          !contentType.includes('application/json'))
      ) {
        throw response
      }

      return response
    })
    .then((response) => {
      return response.json()
    })
    .then((json) => {
      return camelizeKeys(json)
    })
}
