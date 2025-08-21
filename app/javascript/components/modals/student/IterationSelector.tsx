// i18n-key-prefix: iterationSelector
// i18n-namespace: components/modals/student
import React from 'react'
import { Iteration } from '../../types'
import { useIterationSelector } from './useIterationSelector'
import { IterationSelect } from './IterationSelect'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const IterationSelector = ({
  iterations,
  iterationIdx,
  setIterationIdx,
}: {
  iterations: readonly Iteration[]
  iterationIdx: number | null
  setIterationIdx: (idx: number | null) => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/student')
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
          <div className="label">{t('iterationSelector.allIterations')}</div>
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
          <div className="label">{t('iterationSelector.singleIteration')}</div>
        </div>
      </label>
      {selected === 'singleIteration' ? (
        <IterationSelect
          iterations={iterations}
          value={iterationIdx}
          setValue={setIterationIdx}
        />
      ) : null}
    </div>
  )
}
