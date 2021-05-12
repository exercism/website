import React from 'react'
import { Iteration } from '../../types'

export const IterationSelector = ({
  iterations,
  iterationIdx,
  setIterationIdx,
}: {
  iterations: readonly Iteration[]
  iterationIdx: number | null
  setIterationIdx: (idx: number | null) => void
}): JSX.Element => {
  return (
    <div>
      <div>
        <label>
          <input
            type="radio"
            name="published_iterations"
            checked={iterationIdx === null}
            onChange={() => setIterationIdx(null)}
          />
          All iterations
        </label>
      </div>
      <div>
        <label>
          <input
            type="radio"
            name="published_iterations"
            checked={iterationIdx !== null}
            onChange={() => setIterationIdx(iterations[0].idx)}
          />
          Single iteration
        </label>
        {iterationIdx !== null ? (
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
