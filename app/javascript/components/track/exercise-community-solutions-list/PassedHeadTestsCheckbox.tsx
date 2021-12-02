import React from 'react'
import { GraphicalIcon } from '../../common'

export const PassedHeadTestsCheckbox = ({
  checked,
  setChecked,
}: {
  checked: boolean
  setChecked: (value: boolean) => void
}): JSX.Element => {
  return (
    <label className="c-checkbox-wrapper filter">
      <input
        type="checkbox"
        checked={checked}
        onChange={(e) => setChecked(e.target.checked)}
      />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        Passed head tests
      </div>
    </label>
  )
}
