import React from 'react'
import { Iteration } from './MentorDiscussion'
import { IterationButton } from './IterationButton'

export const IterationsList = ({
  iterations,
  current,
  onClick,
}: {
  iterations: Iteration[]
  current: Iteration
  onClick: (iteration: Iteration) => void
}): JSX.Element => {
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
    </nav>
  )
}
