import React from 'react'
import { SolutionProps, Solution } from './Solution'
import pluralize from 'pluralize'
import { PaginatedResult } from '../common/SearchableList'

export const SolutionResults = ({
  data,
}: {
  data: PaginatedResult<SolutionProps>
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {data.results.length}{' '}
          {pluralize('solution', data.results.length)}
        </h3>
      </div>
      <div className="solutions">
        {data.results.map((solution) => {
          return <Solution {...solution} key={solution.uuid} />
        })}
      </div>
    </div>
  )
}
