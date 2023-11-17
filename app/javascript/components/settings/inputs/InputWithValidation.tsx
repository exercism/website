import React, { ChangeEvent, InputHTMLAttributes, useCallback } from 'react'
import { useInvalidField } from '../useInvalidField'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function InputWithValidation(
  inputProps: InputHTMLAttributes<HTMLInputElement> & {
    id: string
    pattern: string
    title: string
    onChange: (e: ChangeEvent<HTMLInputElement>) => void
  }
): JSX.Element {
  const {
    handleInvalid,
    ValidationErrorMessage,
    applyInvalidClassName,
    clearInvalidMessage,
  } = useInvalidField()

  const handleChange = useCallback(
    (e: ChangeEvent<HTMLInputElement>) => {
      if (inputProps.onChange) inputProps.onChange(e)

      clearInvalidMessage()
    },
    [inputProps.onChange, clearInvalidMessage]
  )

  return (
    <>
      <input
        className={assembleClassNames(
          applyInvalidClassName(),
          inputProps.className
        )}
        onInvalid={handleInvalid}
        {...inputProps}
        onChange={handleChange}
      />
      <ValidationErrorMessage />
    </>
  )
}
