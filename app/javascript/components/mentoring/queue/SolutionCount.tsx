import React from 'react'
import pluralize from 'pluralize'
import { GraphicalIcon } from '../../common'

export const SolutionCount = ({
  queryTotal,
  total,
  onResetFilter,
}: {
  queryTotal: number
  total: number
  onResetFilter: () => void
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
      <button type="button" onClick={onResetFilter} className="reset-filters">
        <GraphicalIcon icon="reset" />
        Reset filter
      </button>
    </header>
  )
}
