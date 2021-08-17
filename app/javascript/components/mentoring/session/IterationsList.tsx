import React from 'react'
import { Iteration } from '../../types'
import { IterationButton } from './IterationButton'
import { Icon } from '../../common/Icon'

const NavigationButtons = ({
  iterations,
  current,
  onClick,
}: {
  iterations: readonly Iteration[]
  current: Iteration
  onClick: (iteration: Iteration) => void
}) => {
  const currentIndex = iterations.findIndex((i) => i.idx === current.idx)

  return (
    <React.Fragment>
      <button
        type="button"
        aria-label="Go to previous iteration"
        onClick={() => onClick(iterations[currentIndex - 1])}
        disabled={iterations[0].idx === current.idx}
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
        disabled={iterations[iterations.length - 1].idx === current.idx}
        className="btn-keyboard-shortcut next"
      >
        <div className="--hint">Next</div>
        <div className="--kb">
          <Icon icon="arrow-right" alt="Right arrow" />
        </div>
      </button>
    </React.Fragment>
  )
}

export const IterationsList = ({
  iterations,
  current,
  onClick,
}: {
  iterations: readonly Iteration[]
  current: Iteration
  onClick: (iteration: Iteration) => void
}): JSX.Element => {
  return (
    <>
      <nav className="iterations">
        {iterations.map((iteration) => (
          <IterationButton
            key={iteration.idx}
            iteration={iteration}
            onClick={() => onClick(iteration)}
            selected={current.idx === iteration.idx}
          />
        ))}
      </nav>

      {/* TODO: (optional) Move this into a component that can take either an icon or a character as the contents of --kb */}
      {iterations.length > 1 ? (
        <NavigationButtons
          iterations={iterations}
          current={current}
          onClick={onClick}
        />
      ) : null}
    </>
  )
}
