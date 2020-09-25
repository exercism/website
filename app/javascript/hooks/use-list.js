import { useReducer, useCallback } from 'react'

function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    case 'query.changed':
      return { ...state, query: action.payload.query }
    case 'filter.changed':
      return {
        ...state,
        query: { ...state.query, filter: action.payload.filter, page: 1 },
      }
    case 'sort.changed':
      return {
        ...state,
        query: { ...state.query, sort: action.payload.sort },
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

  const setFilter = useCallback(
    (filter) => {
      dispatch({ type: 'filter.changed', payload: { filter: filter } })
    },
    [dispatch]
  )

  const setPage = useCallback(
    (page) => {
      dispatch({ type: 'page.changed', payload: { page: page } })
    },
    [dispatch]
  )

  const setSort = useCallback(
    (sort) => {
      dispatch({ type: 'sort.changed', payload: { sort: sort } })
    },
    [dispatch]
  )

  const setQuery = useCallback(
    (query) => {
      dispatch({ type: 'query.changed', payload: { query: query } })
    },
    [dispatch]
  )

  return [request, setFilter, setSort, setPage, setQuery]
}
