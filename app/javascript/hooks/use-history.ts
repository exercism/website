import { useRef, useEffect, useState } from 'react'
import { decamelizeKeys } from 'humps'
import { stringify } from 'qs'

function removeEmpty<TParams>(obj: TParams): TParams {
  return Object.entries(obj)
    .filter(([_, v]) => {
      if (typeof v === 'string') {
        return v.length > 0
      } else {
        return v !== null
      }
    })
    .reduce((acc, [k, v]) => ({ ...acc, [k]: v }), {}) as TParams
}

function toQuery<TParams>(params: TParams): string {
  return `?${stringify(decamelizeKeys(params as Record<string, unknown>), {
    arrayFormat: 'brackets',
  })}`
}

function pushState<TParams>(params: TParams) {
  history.pushState(history.state, '', toQuery(params))
}

export function useHistory<TParams>({ pushOn }: { pushOn: TParams }): void {
  const [history, setHistory] = useState(removeEmpty(pushOn))
  const isMounted = useRef(false)

  useEffect(() => {
    const newHistory = removeEmpty(pushOn)

    setHistory(newHistory)
  }, [pushOn])

  useEffect(() => {
    if (!isMounted.current) {
      isMounted.current = true
      return
    }

    pushState<TParams>(history)
  }, [JSON.stringify(history)])
}
