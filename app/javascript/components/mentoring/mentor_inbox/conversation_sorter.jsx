import React from 'react'

const sortingOptions = [
  { value: 'recent', description: 'Sort by Most Recent' },
  { value: 'exercise', description: 'Sort by Exercise' },
  { value: 'student', description: 'Sort by Student' },
]

export function ConversationSorter({ setSort, sort }) {
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
        {sortingOptions.map((sortingOption) => {
          return (
            <option key={sortingOption.value} value={sortingOption.value}>
              {sortingOption.description}
            </option>
          )
        })}
      </select>
    </div>
  )
}
