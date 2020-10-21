import { camelizeKeys } from 'humps'

export async function fetchJSON(endpoint: string, options: any) {
  const headers = {
    'content-type': 'application/json',
    accept: 'application/json',
  }

  try {
    const response = await fetch(
      endpoint,
      Object.assign(options, { headers: headers })
    )

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

    return camelizeKeys(await response.json())
  } catch (responseOrError) {
    return Promise.reject(responseOrError)
  }
}
