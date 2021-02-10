import React from 'react'
import pluralize from 'pluralize'
import { GraphicalIcon } from '../../common'

export const SolutionCount = ({
  unscopedTotal,
  total,
  onResetFilter,
}: {
  unscopedTotal: number
  total: number
  onResetFilter: () => void
}): JSX.Element => {
  return (
    <header className="filtering-header">
      <div className="title">
        <h3>
          Showing {total} {pluralize('request', total)}
        </h3>
        <div className="subtitle">
          {unscopedTotal} queued {pluralize('request', unscopedTotal)}
        </div>
      </div>
      <button type="button" onClick={onResetFilter} className="reset-filters">
        <GraphicalIcon icon="reset" />
        Reset filter
      </button>
    </header>
  )
}
