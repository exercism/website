import React from 'react'

export const TextFilter = ({
  setFilter,
  id,
  filter = '',
  placeholder,
}: {
  setFilter: (filter: string) => void
  id: string
  filter?: string
  placeholder: string
}): JSX.Element => {
  return (
    <input
      id={id}
      onChange={(e) => setFilter(e.target.value)}
      value={filter}
      placeholder={placeholder}
      className="--search"
    />
  )
}
