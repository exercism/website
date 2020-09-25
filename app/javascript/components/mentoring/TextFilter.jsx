import React from 'react'

export function TextFilter({ setFilter, id, filter = '', placeholder }) {
  function handleChange(e) {
    setFilter(e.target.value)
  }

  return (
    <div className="text-filter">
      <label htmlFor={id}>Filter</label>
      <input
        id={id}
        onChange={handleChange}
        value={filter}
        placeholder={placeholder}
      />
    </div>
  )
}
