import React from 'react'

export function TagOption({ value, label, checked, onChange }) {
  const id = `tag-option-${value}`
  return (
    <div className="option">
      <input
        id={id}
        type="checkbox"
        value={value}
        checked={checked}
        onChange={(e) => onChange(e, value)}
      />
      <label htmlFor={id}>{label}</label>
    </div>
  )
}
