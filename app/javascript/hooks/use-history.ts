import { useEffect } from 'react'
import { decamelizeKeys } from 'humps'
import { stringify } from 'qs'

function removeEmpty(obj: any) {
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

export const pushState = (params: any) => {
  const state = removeEmpty(params)
  const queryParams = stringify(decamelizeKeys(state), {
    arrayFormat: 'brackets',
  })

  history.pushState(
    { ...history.state, componentState: state },
    '',
    `?${queryParams}`
  )
}

export const useHistory = ({
  onPopState,
}: {
  onPopState: (query: any) => void
}) => {
  useEffect(() => {
    const popstateHandler = (event: PopStateEvent) => {
      const { componentState } = event.state

      if (!componentState) {
        return
      }

      onPopState(componentState)
    }

    window.addEventListener('popstate', popstateHandler)

    return () => window.removeEventListener('popstate', popstateHandler)
  }, [onPopState])

  return { pushState }
}
