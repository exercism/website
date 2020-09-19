import React, { useReducer, useCallback } from 'react'
import { Solution } from './mentor_solutions_list/solution'
import { Pagination } from './pagination'
import { usePaginatedRequestQuery } from '../../hooks/request_query'

function reducer(state, action) {
  switch (action.type) {
    case 'page.changed':
      return { ...state, query: { ...state.query, page: action.payload.page } }
    default:
      if (process.env.NODE_ENV === 'development') {
        throw new Error(`Unknown action type: ${action.type}`)
      }
      return state
  }
}

export function MentorSolutionsList(props) {
  const [request, dispatch] = useReducer(
    reducer,
    Object.assign({ query: { page: 1 } }, props.request)
  )
  const { status, resolvedData, latestData } = usePaginatedRequestQuery(
    'mentor-solutions-list',
    request
  )

  const setPage = useCallback(
    (page) => {
      dispatch({ type: 'page.changed', payload: { page: page } })
    },
    [dispatch]
  )

  return (
    <div>
      {status === 'error' && <p>Something went wrong</p>}
      {status === 'success' && (
        <table>
          <thead>
            <tr>
              <th>Track icon</th>
              <th>Mentee avatar</th>
              <th>Mentee handle</th>
              <th>Exercise title</th>
              <th>Starred?</th>
              <th>Mentored previously?</th>
              <th>Status</th>
              <th>Updated at</th>
              <th>URL</th>
            </tr>
          </thead>
          <tbody>
            {resolvedData.results.map((solution, key) => (
              <Solution key={key} {...solution} />
            ))}
          </tbody>
        </table>
      )}
      {latestData && (
        <Pagination
          current={request.query.page}
          total={latestData.meta.total}
          setPage={setPage}
        />
      )}
    </div>
  )
}
