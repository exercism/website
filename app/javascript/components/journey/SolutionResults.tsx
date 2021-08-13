import React from 'react'
import { SolutionProps, Solution } from './Solution'
import pluralize from 'pluralize'
import { OrderSwitcher } from './solution-results/OrderSwitcher'
import { PaginatedResult } from '../common/SearchableList'

export type Order = 'newest_first' | 'oldest_first'

const DEFAULT_ORDER = 'newest_first'

export const SolutionResults = ({
  data,
  order,
  setOrder,
}: {
  data: PaginatedResult<SolutionProps>
  setOrder: (order: string) => void
  order: string
}): JSX.Element => {
  return (
    <div>
      <div className="results-title-bar">
        <h3>
          Showing {data.results.length}{' '}
          {pluralize('solution', data.results.length)}
        </h3>
        <OrderSwitcher
          value={(order || DEFAULT_ORDER) as Order}
          setValue={setOrder}
        />
      </div>
      <div className="solutions">
        {data.results.map((solution) => {
          return <Solution {...solution} key={solution.uuid} />
        })}
      </div>
    </div>
  )
}
