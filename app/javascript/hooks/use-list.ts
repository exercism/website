import { useReducer, useCallback, Reducer } from 'react'
import { Request } from './request-query'

export type ListState = Request & {
  query: {
    page?: number
    videoPage?: number
    criteria?: string
    tags?: string[]
    trackSlug?: string
  }
}

type ListAction =
  | {
      type: 'page.changed'
      payload: { page: number } | { [key: string]: number }
    }
  | { type: 'query.changed'; payload: { query: { page: number } } }
  | { type: 'criteria.changed'; payload: { criteria: string } }
  | { type: 'filter.changed'; payload: { filter: string } }
  | { type: 'order.changed'; payload: { order: string } }
  | { type: '' }

const reducer: Reducer<ListState, ListAction> = (
  state: ListState,
  action: ListAction
) => {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    case 'query.changed':
      return { ...state, query: { ...action.payload.query } }
    case 'criteria.changed':
      return {
        ...state,
        query: {
          ...state.query,
          criteria: action.payload.criteria,
        },
      }
    case 'filter.changed':
      return {
        ...state,
        query: {
          ...state.query,
          filter: action.payload.filter,
        },
      }
    case 'order.changed':
      return {
        ...state,
        query: { ...state.query, order: action.payload.order },
      }
    default:
      if (process.env.NODE_ENV === 'development') {
        throw new Error(`Unknown action type: ${action.type}`)
      }
      return state
  }
}

export function useList(initialRequest: Request): {
  request: ListState
  setCriteria: (criteria: string) => void
  setOrder: (order: string) => void
  setPage: (page: number, key?: string) => void
  setQuery: (query: any) => void
  setFilter: (filter: string) => void
} {
  const [request, dispatch] = useReducer(
    reducer,
    Object.assign({ query: { page: 1 } }, initialRequest)
  )

  const setCriteria = useCallback(
    (criteria: string) => {
      dispatch({ type: 'criteria.changed', payload: { criteria } })
    },
    [dispatch]
  )

  const setPage = useCallback(
    (page: number, key = 'page') => {
      dispatch({ type: 'page.changed', payload: { [key]: page } })
    },
    [dispatch]
  )

  const setOrder = useCallback(
    (order: string) => {
      dispatch({ type: 'order.changed', payload: { order } })
    },
    [dispatch]
  )

  const setFilter = useCallback(
    (filter: string) => {
      dispatch({ type: 'filter.changed', payload: { filter } })
    },
    [dispatch]
  )

  const setQuery = useCallback(
    (query) => {
      dispatch({ type: 'query.changed', payload: { query } })
    },
    [dispatch]
  )

  return {
    request,
    setCriteria,
    setOrder,
    setPage,
    setQuery,
    setFilter,
  }
}
