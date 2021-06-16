import React from 'react'
import { Contribution } from './Contribution'
import { Contribution as ContributionProps } from '../types'
import pluralize from 'pluralize'
import { OrderSwitcher } from './contribution-results/OrderSwitcher'

export type Order = 'newest_first' | 'oldest_first'

const DEFAULT_ORDER = 'newest_first'

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
        <OrderSwitcher
          value={(order || DEFAULT_ORDER) as Order}
          setValue={setOrder}
        />
      </div>
      <div className="reputation-tokens">
        {results.map((contribution) => {
          return <Contribution {...contribution} key={contribution.id} />
        })}
      </div>
    </div>
  )
}
