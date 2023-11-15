import React, { InputHTMLAttributes } from 'react'
import { GraphicalIcon } from '@/components/common'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useInvalidField } from '../useInvalidField'
export function LocationInput(
  inputProps: InputHTMLAttributes<HTMLInputElement>
) {
  const { handleInvalid, ValidationErrorMessage, applyInvalidClassName } =
    useInvalidField()
  return (
    <>
      <label
        className={assembleClassNames('c-faux-input', applyInvalidClassName())}
      >
        <GraphicalIcon icon="location" />
        <input
          type="text"
          id="user_location"
          pattern=".{0,255}"
          title="Location must be no longer than 255 characters"
          onInvalid={handleInvalid}
          {...inputProps}
        />
      </label>
      <ValidationErrorMessage />
    </>
  )
}
