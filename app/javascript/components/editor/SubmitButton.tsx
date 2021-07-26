import React from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'

export const SubmitButton = ({
  onClick,
  disabled,
}: {
  onClick: () => void
  disabled: boolean
}) => (
  <GenericTooltip
    disabled={!disabled}
    content={
      'You need to get the tests passing before you can submit your solution'
    }
  >
    <div className="submit-btn">
      <button
        type="button"
        onClick={onClick}
        disabled={disabled}
        className="btn-primary btn-s"
      >
        <span>Submit</span>
        <div className="kb-shortcut">F3</div>
      </button>
    </div>
  </GenericTooltip>
)
