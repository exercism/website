import React from 'react'
import { Badge, BadgeProps } from './Badge'
import pluralize from 'pluralize'

export const BadgeResults = ({
  results,
  order,
  setOrder,
}: {
  results: BadgeProps[]
  setOrder: (order: string) => void
  order: string
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {results.length} {pluralize('badge', results.length)}
        </h3>
        <div className="c-select order">
          <select onChange={(e) => setOrder(e.target.value)} value={order}>
            <option value="newest_first">Sort by Newest First</option>
            <option value="oldest_first">Sort by Oldest First</option>
          </select>
        </div>
      </div>
      <div className="badges">
        {results.map((badge) => {
          return <Badge {...badge} key={badge.name} />
        })}
      </div>
    </div>
  )
}
