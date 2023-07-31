import React from 'react'
import { GraphicalIcon } from '../../common'
import { TestsStatus } from '../ExerciseCommunitySolutionsList'

export const TestsStatusCheckbox = ({
  value,
  setValue,
}: {
  value: TestsStatus
  setValue: (value: TestsStatus) => void
}): JSX.Element => {
  return (
    <label className="c-checkbox-wrapper filter">
      <input
        type="checkbox"
        checked={value === 'passed'}
        onChange={(e) => setValue(e.target.checked ? 'passed' : undefined)}
      />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        Tests passing
      </div>
    </label>
  )
}
