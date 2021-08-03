import React, { useCallback } from 'react'
import currency from 'currency.js'

export const AmountButton = ({
  value,
  onClick,
  current,
}: {
  value: currency
  onClick: (value: currency) => void
  current: currency
}): JSX.Element => {
  const handleClick = useCallback(() => {
    onClick(value)
  }, [onClick, value])

  const classNames = [
    'btn-enhanced',
    'btn-l',
    current.value === value.value ? 'selected' : '',
  ].filter((className) => className.length > 0)

  return (
    <button className={classNames.join(' ')} onClick={handleClick}>
      ${value.dollars()}
    </button>
  )
}
