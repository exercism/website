import React from 'react'

export function TagOption({ value, label, checked, onChange }) {
  const id = `tag-option-${value}`
  return (
    <>
      <label htmlFor={id}>{label}</label>
      <input
        id={id}
        type="checkbox"
        value={value}
        checked={checked}
        onChange={(e) => onChange(e, value)}
      />
    </>
  )
}
