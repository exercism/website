import React, { FormEventHandler } from 'react'

export type ToggleButtonProps = {
  checked: boolean
  onToggle: FormEventHandler<HTMLButtonElement>
  className?: string
}

export function ToggleButton({
  onToggle,
  checked,
  className = '',
}: ToggleButtonProps): JSX.Element {
  return (
    <button
      type="button"
      onChange={onToggle}
      className={`c-toggle-button ${className}`}
    >
      <label className="switch">
        <input type="checkbox" readOnly checked={checked} />
        <span className="slider round" />
      </label>
    </button>
  )
}
