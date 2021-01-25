import React from 'react'
import { SolutionProps, Solution } from './Solution'
import pluralize from 'pluralize'

export const SolutionResults = ({
  results,
  sort,
  setSort,
}: {
  results: SolutionProps[]
  setSort: (sort: string) => void
  sort: string
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {results.length} {pluralize('solution', results.length)}
        </h3>
        <div className="c-select order">
          <select onChange={(e) => setSort(e.target.value)} value={sort}>
            <option value="newest_first">Sort by Newest First</option>
            <option value="oldest_first">Sort by Oldest First</option>
          </select>
        </div>
      </div>
      <div className="solutions">
        {results.map((solution) => {
          return <Solution {...solution} key={solution.id} />
        })}
      </div>
    </div>
  )
}
