import React, { ChangeEvent, InputHTMLAttributes, useCallback } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useInvalidField } from '../useInvalidField'
export function FauxInputWithValidation(
  inputProps: InputHTMLAttributes<HTMLInputElement> & {
    icon: string
    id: string
    pattern: string
    title: string
  }
) {
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
      <label
        className={assembleClassNames('c-faux-input', applyInvalidClassName())}
      >
        <GraphicalIcon icon={inputProps.icon} />
        <input
          onInvalid={handleInvalid}
          {...inputProps}
          onChange={handleChange}
        />
      </label>
      <ValidationErrorMessage />
    </>
  )
}
