import React from 'react'

export function TagOption({ value, label, checked, onChange }) {
  // TODO: ids shouldn't have : in them so parse it out
  const id = `tag-option-${value}`
  return (
    <div className="--option">
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
