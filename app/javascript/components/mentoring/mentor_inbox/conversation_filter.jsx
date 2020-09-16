import React from 'react'

export function ConversationFilter({ setFilter, filter }) {
  function handleChange(e) {
    setFilter(e.target.value)
  }

  return (
    <div className="conversation-filter">
      <label htmlFor="conversation-filter">Filter</label>
      <input
        id="conversation-filter"
        onChange={handleChange}
        value={filter}
        placeholder="Filter by student or exercism name"
      />
    </div>
  )
}
