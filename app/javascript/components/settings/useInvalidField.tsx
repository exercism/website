import React, { useCallback, useState } from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const INVALID_INPUT_STYLES = '!border-1 !border-orange mb-8'

export function useInvalidField() {
  const { t } = useAppTranslation('components/settings/useInvalidField.tsx')
  const [invalidMessage, setInvalidMessage] = useState<string>('')

  const isInvalid = invalidMessage.length > 0

  const applyInvalidClassName = useCallback(() => {
    return isInvalid ? INVALID_INPUT_STYLES : null
  }, [invalidMessage])

  const handleInvalid = useCallback((e) => {
    e.preventDefault()
    setInvalidMessage(e.target.title)
  }, [])

  const clearInvalidMessage = useCallback(() => {
    setInvalidMessage('')
  }, [invalidMessage])

  function ValidationErrorMessage() {
    return isInvalid ? (
      <span className="text-orange font-semibold">{invalidMessage}</span>
    ) : null
  }

  return {
    invalidMessage,
    isInvalid,
    applyInvalidClassName,
    handleInvalid,
    clearInvalidMessage,
    ValidationErrorMessage,
  }
}

export function createMaxLengthAttributes(
  fieldName: string,
  maxLength: number,
  t
) {
  const pattern = `.{0,${maxLength}}`
  const title = t('field.mustBeNoLongerThan', { fieldName, maxLength })
  return { pattern, title }
}
