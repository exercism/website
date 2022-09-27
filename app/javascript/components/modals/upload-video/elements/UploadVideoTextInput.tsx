import React from 'react'
type UploadVideoInputProps = {
  label: string
  disabled?: boolean
  className?: string
}

export function UploadVideoTextInput({
  label,
  disabled = false,
  className = '',
}: UploadVideoInputProps): JSX.Element {
  return (
    <label
      className={`text-label text-btnBorder flex flex-col mb-16 ${className}`}
    >
      <span className="mb-8">{label}</span>
      <input
        type="text"
        disabled={disabled}
        placeholder="This is placeholder text"
        className={`font-body ${disabled ? '!bg-disabledLight' : ''}`}
      />
    </label>
  )
}
