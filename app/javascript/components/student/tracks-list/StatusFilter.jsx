import React from 'react'

export function StatusFilter({ options, dispatch }) {
  function handleChange(e) {
    dispatch({ type: 'status.changed', payload: { status: e.target.value } })
  }

  return (
    <div>
      <label htmlFor="student-track-list-status-filter">Status</label>
      <select id="student-track-list-status-filter" onChange={handleChange}>
        {options.map((option) => {
          return (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          )
        })}
      </select>
    </div>
  )
}
