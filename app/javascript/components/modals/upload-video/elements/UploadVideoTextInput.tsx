import React from 'react'
type UploadVideoInputProps = {
  label: string
  disabled?: boolean
  className?: string
  defaultValue?: string
  onChange?: React.ChangeEventHandler<HTMLInputElement>
  name: string
  error?: boolean
}

export function UploadVideoTextInput({
  label,
  disabled = false,
  className = '',
  name,
  defaultValue,
  error,
}: UploadVideoInputProps): JSX.Element {
  return (
    <label
      className={`text-label text-btnBorder flex flex-col mb-16 ${className}`}
    >
      <span className="mb-8">{label}</span>
      <input
        type="text"
        name={name}
        defaultValue={defaultValue}
        required
        disabled={disabled}
        placeholder="This is placeholder text"
        className={`font-body ${disabled ? '!bg-disabledLight' : ''} `}
      />
      {error && <span className="text-red">ERROR!!</span>}
    </label>
  )
}
