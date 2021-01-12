import React from 'react'
import { Iteration } from '../Discussion'
import { IterationButton } from './IterationButton'

export const IterationsList = ({
  iterations,
  current,
  onClick,
}: {
  iterations: readonly Iteration[]
  current: Iteration
  onClick: (iteration: Iteration) => void
}): JSX.Element => {
  const currentIndex = iterations.indexOf(current)

  return (
    <nav className="iterations">
      {iterations.map((iteration) => (
        <IterationButton
          key={iteration.idx}
          iteration={iteration}
          onClick={() => onClick(iteration)}
          selected={current === iteration}
        />
      ))}

      <button
        type="button"
        aria-label="Go to previous iteration"
        onClick={() => onClick(iterations[currentIndex - 1])}
        disabled={iterations[0] === current}
      >
        Previous
      </button>
      <button
        type="button"
        aria-label="Go to next iteration"
        onClick={() => onClick(iterations[currentIndex + 1])}
        disabled={iterations[iterations.length - 1] === current}
      >
        Next
      </button>
    </nav>
  )
}
