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
    <div className="iteration-selector">
      <label className="c-radio-wrapper">
        <input
          type="radio"
          name="published_iterations"
          checked={selected === 'allIterations'}
          onChange={() => onSelected('allIterations')}
        />
        <div className="row">
          <div className="c-radio" />
          <div className="label">All iterations</div>
        </div>
      </label>
      <label className="c-radio-wrapper">
        <input
          type="radio"
          name="published_iterations"
          checked={selected === 'singleIteration'}
          onChange={() => onSelected('singleIteration')}
        />
        <div className="row">
          <div className="c-radio" />
          <div className="label">Single iteration</div>
        </div>
      </label>
      {selected === 'singleIteration' ? (
        <div className="c-select">
          <select onChange={(e) => setIterationIdx(parseInt(e.target.value))}>
            {iterations.map((iteration) => {
              return (
                <option key={iteration.idx} value={iteration.idx}>
                  Iteration {iteration.idx}
                </option>
              )
            })}
          </select>
        </div>
      ) : null}
    </div>
  )
}
