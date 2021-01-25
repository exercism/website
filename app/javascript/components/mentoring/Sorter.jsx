import React from 'react'

export function Sorter({ setOrder, order, sortOptions, id }) {
  function handleChange(e) {
    setOrder(e.target.value)
  }

  return (
    <div className="c-select">
      <select id={id} onChange={handleChange} value={order}>
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
