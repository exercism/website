import React from 'react'

export function ConversationSorter({ sortOptions, setSort, sort }) {
  function handleChange(e) {
    setSort(e.target.value)
  }

  return (
    <div className="conversation-sorter">
      <label htmlFor="conversation-sorter-sort">Sort</label>
      <select
        id="conversation-sorter-sort"
        onChange={handleChange}
        value={sort}
      >
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
