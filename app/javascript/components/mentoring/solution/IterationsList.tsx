import React from 'react'
import { Iteration } from '../Solution'
import { IterationButton } from './IterationButton'
import { Icon } from '../../common/Icon'

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
    <>
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

      {/* TODO: Move this into a component that can take either an icon or a character as the contents of --kb */}
      <button
        type="button"
        aria-label="Go to previous iteration"
        onClick={() => onClick(iterations[currentIndex - 1])}
        disabled={iterations[0] === current}
        className="btn-keyboard-shortcut previous"
      >
        <div className="--kb">
          <Icon icon="arrow-left" alt="Left arrow" />
        </div>
        <div className="--hint">Previous</div>
      </button>
      <button
        type="button"
        aria-label="Go to next iteration"
        onClick={() => onClick(iterations[currentIndex + 1])}
        disabled={iterations[iterations.length - 1] === current}
        className="btn-keyboard-shortcut next"
      >
        <div className="--hint">Next</div>
        <div className="--kb">
          <Icon icon="arrow-right" alt="Right arrow" />
        </div>
      </button>
    </>
  )
}
