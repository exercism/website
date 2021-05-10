import { useReducer, useCallback } from 'react'

function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    case 'query.changed':
      return { ...state, query: action.payload.query }
    case 'criteria.changed':
      return {
        ...state,
        query: { ...state.query, criteria: action.payload.criteria, page: 1 },
      }
    case 'filter.changed':
      return {
        ...state,
        query: { ...state.query, filter: action.payload.filter, page: 1 },
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

export function useList(initialRequest) {
  const [request, dispatch] = useReducer(
    reducer,
    Object.assign({ query: { page: 1 } }, initialRequest)
  )

  const setCriteria = useCallback(
    (criteria) => {
      dispatch({ type: 'criteria.changed', payload: { criteria: criteria } })
    },
    [dispatch]
  )

  const setPage = useCallback(
    (page) => {
      dispatch({ type: 'page.changed', payload: { page: page } })
    },
    [dispatch]
  )

  const setOrder = useCallback(
    (order) => {
      dispatch({ type: 'order.changed', payload: { order: order } })
    },
    [dispatch]
  )

  const setFilter = useCallback(
    (filter) => {
      dispatch({ type: 'filter.changed', payload: { filter: filter } })
    },
    [dispatch]
  )

  const setQuery = useCallback(
    (query) => {
      dispatch({ type: 'query.changed', payload: { query: query } })
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
