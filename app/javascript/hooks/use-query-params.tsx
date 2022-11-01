import { decamelizeKeys } from 'humps'
import { useEffect, useRef } from 'react'

type RequestQueryParamObject = Record<string, string>

function pushQueryParams(key: string, value: string): void {
  const location = `${window.location}`
  const valueAsString = `${value}`
  const url = new URL(location)

  if (value && valueAsString.length > 0) {
    value
    url.searchParams.set(key, valueAsString)
  } else {
    url.searchParams.delete(key)
  }

  window.history.pushState({}, '', url)
}

export function useQueryParams(obj: RequestQueryParamObject): void {
  const isMounted = useRef(false)

  useEffect(() => {
    if (!isMounted.current) {
      isMounted.current = true
      return
    }

    for (const [key, value] of Object.entries(decamelizeKeys(obj))) {
      pushQueryParams(key, value)
    }
  }, [obj])
}
