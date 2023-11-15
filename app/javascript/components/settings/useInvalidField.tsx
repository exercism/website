import React, { useCallback, useState } from 'react'

const INVALID_CLASSNAMES = '!border-1 !border-orange mb-8'

export function useInvalidField() {
  const [invalidMessage, setInvalidMessage] = useState<string>('')

  const isInvalid = useCallback(() => {
    return invalidMessage.length > 0
  }, [invalidMessage])

  const applyInvalidClassName = useCallback(() => {
    return isInvalid() ? INVALID_CLASSNAMES : null
  }, [invalidMessage, isInvalid])

  const handleInvalid = useCallback((e) => {
    console.log(e)
    e.preventDefault()
    setInvalidMessage(e.target.title)
  }, [])

  function ValidationErrorMessage() {
    return isInvalid() ? (
      <span className="text-orange font-semibold">{invalidMessage}</span>
    ) : null
  }

  return {
    invalidMessage,
    isInvalid,
    applyInvalidClassName,
    handleInvalid,
    ValidationErrorMessage,
  }
}

export function createMaxLengthAttributes(
  fieldName: string,
  maxLength: number
) {
  const pattern = `.{0,${maxLength}}`
  const title = `${fieldName} must be no longer than ${maxLength} characters`
  return { pattern, title }
}
