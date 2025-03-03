import React, { FormEventHandler } from 'react'

export type ToggleButtonProps = {
  checked: boolean
  onToggle: FormEventHandler<HTMLButtonElement>
  className?: string
  disabled?: boolean
  style?: React.CSSProperties
}

export function ToggleButton({
  onToggle,
  checked,
  className = '',
  disabled = false,
  style,
}: ToggleButtonProps): JSX.Element {
  return (
    <button
      style={style}
      type="button"
      onChange={onToggle}
      className={`c-toggle-button ${className}`}
    >
      <label className="switch">
        <input disabled={disabled} type="checkbox" readOnly checked={checked} />
        <span className="slider round" />
      </label>
    </button>
  )
}
