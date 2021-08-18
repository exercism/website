import React from 'react'

export const TagOption = ({
  value,
  label,
  checked,
  onChange,
}: {
  value: string
  label: string
  checked: boolean
  onChange: (e: React.ChangeEvent<HTMLInputElement>, value: string) => void
}): JSX.Element => {
  // TODO: (optional) ids shouldn't have : in them so parse it out
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
