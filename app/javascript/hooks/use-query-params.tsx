import { decamelizeKeys } from 'humps'
import { useEffect, useRef } from 'react'

type RequestQueryParamObject = Record<string, string>

function pushQueryParams(key: string, value: string): void {
  const url = new URL(window.location.toString())

  if (value && `${value}`.length > 0) {
    url.searchParams.set(key, value)
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
