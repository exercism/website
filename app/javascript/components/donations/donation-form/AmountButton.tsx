import React, { useCallback } from 'react'

export const AmountButton = ({
  value,
  onClick,
  current,
}: {
  value: number
  onClick: (value: number) => void
  current: number
}): JSX.Element => {
  const handleClick = useCallback(() => {
    onClick(value)
  }, [onClick, value])

  const classNames = [
    'btn-enhanced',
    'btn-l',
    current === value ? 'selected' : '',
  ].filter((className) => className.length > 0)

  return (
    <button className={classNames.join(' ')} onClick={handleClick}>
      ${value}
    </button>
  )
}
