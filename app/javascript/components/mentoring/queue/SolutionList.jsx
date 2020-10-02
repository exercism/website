import React from 'react'
import { Solution } from './Solution'
import { Pagination } from '../Pagination'
import { usePaginatedRequestQuery } from '../../../hooks/request-query'
import { Loading } from '../../common/Loading'

export function SolutionList({ request, setPage }) {
  const {
    isLoading,
    isError,
    isSuccess,
    resolvedData,
    latestData,
  } = usePaginatedRequestQuery('mentor-solutions-list', request)

  return (
    <div>
      {isLoading && <Loading />}
      {isError && <p>Something went wrong</p>}
      {isSuccess && (
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
