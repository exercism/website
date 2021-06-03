import React from 'react'
import { SortOption } from './Inbox'

export const Sorter = ({
  setOrder,
  order,
  sortOptions,
  id,
}: {
  setOrder: (order: string) => void
  order: string
  sortOptions: readonly SortOption[]
  id: string
}): JSX.Element => {
  return (
    <div className="c-select">
      <select id={id} onChange={(e) => setOrder(e.target.value)} value={order}>
        {sortOptions.map((sortOption) => {
          return (
            <option key={sortOption.value} value={sortOption.value}>
              {sortOption.label}
            </option>
          )
        })}
      </select>
    </div>
  )
}
