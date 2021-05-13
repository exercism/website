import React from 'react'
import { Iteration } from '../../types'

type IterationOption = 'allIterations' | 'singleIteration'

type IterationSelectorHandler = {
  onSelected: (option: IterationOption) => void
  selected: IterationOption
}

export const useIterationSelector = ({
  iterationIdx,
  setIterationIdx,
  iterations,
}: {
  iterationIdx: number | null
  setIterationIdx: (idx: number | null) => void
  iterations: readonly Iteration[]
}): IterationSelectorHandler => {
  return {
    onSelected: (option: IterationOption) => {
      option === 'allIterations'
        ? setIterationIdx(null)
        : setIterationIdx(iterations[0].idx)
    },
    selected: iterationIdx === null ? 'allIterations' : 'singleIteration',
  }
}
