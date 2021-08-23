import React, { useCallback } from 'react'
import currency from 'currency.js'

export const AmountButton = ({
  value,
  onClick,
  current,
  className = '',
}: {
  value: currency
  onClick: (value: currency) => void
  current: currency
  className?: string
}): JSX.Element => {
  const handleClick = useCallback(() => {
    onClick(value)
  }, [onClick, value])

  const classNames = [
    className,
    current.value === value.value ? 'selected' : '',
  ].filter((n) => n.length > 0)

  return (
    <button
      className={classNames.join(' ')}
      onClick={handleClick}
      type="button"
    >
      ${value.dollars()}
    </button>
  )
}
