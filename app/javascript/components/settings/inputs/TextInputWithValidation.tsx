import React, { InputHTMLAttributes } from 'react'
import { useInvalidField } from '../useInvalidField'
import { assembleClassNames } from '@/utils/assemble-classnames'

export function TextInputWithValidation(
  inputProps: InputHTMLAttributes<HTMLInputElement> & {
    id: string
    pattern: string
    title: string
  }
): JSX.Element {
  const { handleInvalid, ValidationErrorMessage, applyInvalidClassName } =
    useInvalidField()
  return (
    <>
      <input
        type="text"
        className={assembleClassNames(
          applyInvalidClassName(),
          inputProps.className
        )}
        onInvalid={handleInvalid}
        {...inputProps}
      />
      <ValidationErrorMessage />
    </>
  )
}
