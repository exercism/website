import React from 'react'
import { Icon } from '../common/Icon'

export function TextFilter({ setFilter, id, filter = '', placeholder }) {
  function handleChange(e) {
    setFilter(e.target.value)
  }

  return (
    <input
      id={id}
      onChange={handleChange}
      value={filter}
      placeholder={placeholder}
      className="--search"
    />
  )
}
