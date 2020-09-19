import React from 'react'

const sortingOptions = [
  { value: 'recent', description: 'Sort by Most Recent' },
  { value: 'exercise', description: 'Sort by Exercise' },
  { value: 'student', description: 'Sort by Student' },
]

export function Sorter({ setSort, sort, id }) {
  function handleChange(e) {
    setSort(e.target.value)
  }

  return (
    <div className="sorter">
      <label htmlFor={id}>Sort</label>
      <select id={id} onChange={handleChange} value={sort}>
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
