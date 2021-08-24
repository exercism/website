import React, { useCallback } from 'react'
import currency from 'currency.js'

export const AmountButton = ({
  value,
  onClick,
  className = '',
  selected = false,
}: {
  value: currency
  onClick: (value: currency) => void
  className?: string
  selected?: boolean
}): JSX.Element => {
  const handleClick = useCallback(() => {
    onClick(value)
  }, [onClick, value])

  const classNames = [className, selected ? 'selected' : ''].filter(
    (n) => n.length > 0
  )

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
