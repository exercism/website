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
  placeholder?: string
}

export function UploadVideoTextInput({
  label,
  readOnly = false,
  className = '',
  name,
  defaultValue,
  error,
  errorMessage,
  placeholder,
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
        placeholder={placeholder}
        className={`font-body ${readOnly ? '!bg-disabledLight' : ''} `}
      />
      {error && (
        <span className="c-alert--danger text-16 font-body mt-16 normal-case">
          {errorMessage}
        </span>
      )}
    </label>
  )
}
