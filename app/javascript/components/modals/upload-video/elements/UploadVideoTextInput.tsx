import React from 'react'
type UploadVideoInputProps = {
  label: string
  readOnly?: boolean
  className?: string
  defaultValue?: string
  onChange?: React.ChangeEventHandler<HTMLInputElement>
  name: string
  error?: boolean
  errorMessage?: string
}

export function UploadVideoTextInput({
  label,
  readOnly = false,
  className = '',
  name,
  defaultValue,
  error,
  errorMessage,
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
        readOnly={readOnly}
        required
        placeholder="This is placeholder text"
        className={`font-body ${readOnly ? '!bg-disabledLight' : ''} `}
      />
      {error && <span className="text-red">{errorMessage}</span>}
    </label>
  )
}
