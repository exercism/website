import React from 'react'
import { GraphicalIcon } from '../../common'
import { MentoringStatus } from '../ExerciseCommunitySolutionsList'

export const MentoringStatusCheckbox = ({
  value,
  setValue,
}: {
  value: MentoringStatus
  setValue: (value: MentoringStatus) => void
}): JSX.Element => {
  return (
    <label className="c-checkbox-wrapper filter">
      <input
        type="checkbox"
        checked={value === 'finished'}
        onChange={(e) => setValue(e.target.checked ? 'finished' : undefined)}
      />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        Received mentoring
      </div>
    </label>
  )
}
