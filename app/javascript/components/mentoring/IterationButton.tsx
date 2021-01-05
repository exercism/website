import React from 'react'

export const IterationButton = ({
  idx,
  selected,
  onClick,
}: {
  idx: number
  selected: boolean
  onClick: () => void
}): JSX.Element => {
  const classNames = ['iteration']

  if (selected) {
    classNames.push('active')
  }

  return (
    <button
      key={idx}
      type="button"
      className={classNames.join(' ')}
      aria-current={selected}
      aria-label={`Go to iteration ${idx}`}
      disabled={selected}
      onClick={onClick}
    >
      {idx}
    </button>
  )
}
