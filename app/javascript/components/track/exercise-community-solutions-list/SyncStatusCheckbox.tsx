import React from 'react'
import { GraphicalIcon } from '../../common'
import { SyncStatus } from '../ExerciseCommunitySolutionsList'

export const SyncStatusCheckbox = ({
  value,
  setValue,
}: {
  value: SyncStatus
  setValue: (value: SyncStatus) => void
}): JSX.Element => {
  return (
    <label className="c-checkbox-wrapper filter">
      <input
        type="checkbox"
        checked={value === 'up_to_date'}
        onChange={(e) => setValue(e.target.checked ? 'up_to_date' : undefined)}
      />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        Up-to-date
      </div>
    </label>
  )
}
