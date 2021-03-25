import React, { useCallback } from 'react'

export const SearchBar = ({
  value,
  setValue,
}: {
  value: string
  setValue: (value: string) => void
}): JSX.Element => {
  const handleChange = useCallback(
    (e) => {
      setValue(e.target.value)
    },
    [setValue]
  )

  return <input className="--search" value={value} onChange={handleChange} />
}
