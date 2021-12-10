import React from 'react'
import { GraphicalIcon } from '.'

export const Checkbox = ({
  checked,
  setChecked,
  children,
}: {
  checked: boolean
  setChecked: (value: boolean) => void
  children: React.ReactNode
}): JSX.Element => {
  return (
    <label className="c-checkbox-wrapper filter">
      <input
        type="checkbox"
        checked={checked || false}
        onChange={(e) => setChecked(e.target.checked)}
      />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        {children}
      </div>
    </label>
  )
}
