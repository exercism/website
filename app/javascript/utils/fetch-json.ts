import { camelizeKeys } from 'humps'

export class ApiError extends Error {
  constructor(public type: string, public message: string) {
    super(message)
    this.name = this.constructor.name
    this.type = type
    Object.setPrototypeOf(this, ApiError.prototype)
  }
}

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
        throw new Error('Received non-JSON response')
      }

      if (!response.ok) {
        const errorData = await response.json()
        const errorType = errorData.error.type
        const errorMessage = errorData.error.message || 'An error occurred'
        throw new ApiError(errorType, errorMessage)
      }

      return response.json()
    })
    .then((json) => camelizeKeys(json) as T)
}
