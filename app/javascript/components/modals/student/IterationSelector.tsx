import React from 'react'
import { Iteration } from '../../types'
import { useIterationSelector } from './useIterationSelector'

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
    <div>
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
          <select onChange={(e) => setIterationIdx(parseInt(e.target.value))}>
            {iterations.map((iteration) => {
              return (
                <option key={iteration.idx} value={iteration.idx}>
                  Iteration {iteration.idx}
                </option>
              )
            })}
          </select>
        ) : null}
      </div>
    </div>
  )
}
