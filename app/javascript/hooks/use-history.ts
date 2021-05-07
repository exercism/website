import { useRef, useEffect } from 'react'
import { decamelizeKeys } from 'humps'
import { stringify } from 'qs'

function removeEmpty<TParams>(obj: TParams) {
  return Object.entries(obj)
    .filter(([_, v]) => {
      if (typeof v === 'string') {
        return v.length > 0
      } else {
        return v !== null
      }
    })
    .reduce((acc, [k, v]) => ({ ...acc, [k]: v }), {})
}

function toQuery<TParams>(params: TParams): string {
  const state = removeEmpty(params)

  return `?${stringify(decamelizeKeys(state), { arrayFormat: 'brackets' })}`
}

function pushState<TParams>(params: TParams) {
  history.pushState(history.state, '', toQuery(params))
}

function replaceState<TParams>(params: TParams) {
  history.replaceState(history.state, '', toQuery(params))
}

export function useHistory<TParams>({
  pushOn,
  replaceOn,
}: {
  pushOn: TParams
  replaceOn: TParams
}): void {
  const isMounted = useRef(false)

  useEffect(() => {
    if (!isMounted.current) {
      isMounted.current = true
      return
    }

    pushState<TParams>(pushOn)
  }, [pushOn])

  useEffect(() => {
    if (!isMounted.current) {
      isMounted.current = true
      return
    }

    replaceState<TParams>(replaceOn)
  }, [replaceOn])
}
