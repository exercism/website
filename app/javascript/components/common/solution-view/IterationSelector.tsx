import React from 'react'
import { Iteration } from '../../types'
import { useIterationSelector } from '../../modals/student/useIterationSelector'

export const IterationSelector = ({
  iterations,
  iterationIdx,
  setIterationIdx,
}: {
  iterations: readonly Iteration[]
  iterationIdx: number | null
  setIterationIdx: (idx: number | null) => void
}): JSX.Element => {
  const { selected, onSelected } = useIterationSelector({
    iterationIdx,
    setIterationIdx,
    iterations,
  })

  return (
    <div className="iteration-selector">
      <div>
        <label>
          <input
            type="radio"
            name="published_iterations"
            checked={selected === 'allIterations'}
            onChange={() => onSelected('allIterations')}
          />
          All iterations
        </label>
      </div>
      <div>
        <label>
          <input
            type="radio"
            name="published_iterations"
            checked={selected === 'singleIteration'}
            onChange={() => onSelected('singleIteration')}
          />
          Single iteration
        </label>
        {selected === 'singleIteration' ? (
          <div>
            {iterations.map((iteration) => {
              return (
                <button
                  key={iteration.idx}
                  onClick={() => setIterationIdx(iteration.idx)}
                  disabled={iteration.idx === iterationIdx}
                >
                  {iteration.idx}
                </button>
              )
            })}
          </div>
        ) : null}
      </div>
    </div>
  )
}
