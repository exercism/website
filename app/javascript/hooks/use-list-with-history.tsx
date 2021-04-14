import { useReducer, useCallback, useEffect } from 'react'
import { pushState, useHistory } from './use-history'
import { Request } from './request-query'

type Action =
  | { type: 'page.changed'; payload: { page: number } }
  | { type: 'query.changed'; payload: { query: any } }
  | { type: 'query.popped'; payload: { query: any } }
  | { type: 'criteria.changed'; payload: { criteria: string } }
  | { type: 'filter.changed'; payload: { filter: any } }
  | { type: 'order.changed'; payload: { order: string } }

type RequestWithHistory = Request & { isPop: boolean }

const reducer = (
  state: RequestWithHistory,
  action: Action
): RequestWithHistory => {
  switch (action.type) {
    case 'page.changed':
      return {
        ...state,
        query: { ...state.query, page: action.payload.page },
        isPop: false,
      }
    case 'query.changed':
      return { ...state, query: action.payload.query, isPop: false }
    case 'query.popped':
      return { ...state, query: action.payload.query, isPop: true }
    case 'criteria.changed':
      return {
        ...state,
        query: { ...state.query, criteria: action.payload.criteria, page: 1 },
        isPop: false,
      }
    case 'filter.changed':
      return {
        ...state,
        query: { ...state.query, filter: action.payload.filter, page: 1 },
        isPop: false,
      }
    case 'order.changed':
      return {
        ...state,
        query: { ...state.query, order: action.payload.order },
        isPop: false,
      }
  }
}

export const useListWithHistory = (initialRequest: Request) => {
  const [request, dispatch] = useReducer(
    reducer,
    Object.assign({ query: { page: 1 }, isPop: true }, initialRequest)
  )

  const setCriteria = useCallback((criteria) => {
    dispatch({ type: 'criteria.changed', payload: { criteria: criteria } })
  }, [])

  const setPage = useCallback((page) => {
    dispatch({ type: 'page.changed', payload: { page: page } })
  }, [])

  const setOrder = useCallback((order) => {
    dispatch({ type: 'order.changed', payload: { order: order } })
  }, [])

  const setFilter = useCallback((filter) => {
    dispatch({ type: 'filter.changed', payload: { filter: filter } })
  }, [])

  const setQuery = useCallback((query) => {
    dispatch({ type: 'query.changed', payload: { query: query } })
  }, [])

  const setQueryPop = useCallback((query) => {
    dispatch({ type: 'query.popped', payload: { query: query } })
  }, [])

  useHistory({ onPopState: setQueryPop })

  useEffect(() => {
    if (request.isPop) {
      return
    }

    pushState(request.query)
  }, [request.query, request.isPop])

  return { request, setCriteria, setOrder, setPage, setQuery, setFilter }
}
