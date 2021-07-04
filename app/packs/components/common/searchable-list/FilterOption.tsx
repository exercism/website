import React from 'react'

export const FilterOption = ({
  value,
  label,
  checked,
  onChange,
  category,
}: {
  value: string
  label: string
  checked: boolean
  onChange: (
    e: React.ChangeEvent<HTMLInputElement>,
    category: string,
    value: string
  ) => void
  category: string
}): JSX.Element => {
  const id = `filter-option-${category}-${value}`

  return (
    <div className="--option">
      <input
        id={id}
        type="radio"
        value={value}
        checked={checked}
        onChange={(e) => onChange(e, category, value)}
      />
      <label htmlFor={id}>{label}</label>
    </div>
  )
}
