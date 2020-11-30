import React from 'react'
import { Icon } from '../common/Icon'

export function TextFilter({ setFilter, id, filter = '', placeholder }) {
  function handleChange(e) {
    setFilter(e.target.value)
  }

  return (
    <div className="c-mentor-text-filter">
      <Icon icon="search" alt="Filter results" />
      <input
        id={id}
        onChange={handleChange}
        value={filter}
        placeholder={placeholder}
      />
    </div>
  )
}
