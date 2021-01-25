import React from 'react'
import { ContributionProps, Contribution } from './Contribution'
import pluralize from 'pluralize'

export const ContributionResults = ({
  results,
  order,
  setOrder,
}: {
  results: ContributionProps[]
  setOrder: (order: string) => void
  order: string
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {results.length} {pluralize('contribution', results.length)}
        </h3>
        <div className="c-select order">
          <select onChange={(e) => setOrder(e.target.value)} value={order}>
            <option value="oldest_first">Sort by Oldest First</option>
            <option value="newest_first">Sort by Newest First</option>
          </select>
        </div>
      </div>
      <div className="reputation-tokens">
        {results.map((contribution) => {
          return <Contribution {...contribution} key={contribution.id} />
        })}
      </div>
    </div>
  )
}
