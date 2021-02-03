import React from 'react'
import pluralize from 'pluralize'

export const SolutionCount = ({
  queryTotal,
  total,
}: {
  queryTotal: number
  total: number
}): JSX.Element => {
  return (
    <header className="filtering-header">
      <div className="title">
        <h3>
          Showing {queryTotal} {pluralize('request', queryTotal)}
        </h3>
        <div className="subtitle">
          {total} queued {pluralize('request', total)}
        </div>
      </div>
    </header>
  )
}
