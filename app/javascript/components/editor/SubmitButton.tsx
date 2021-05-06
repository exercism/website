import React from 'react'

export const SubmitButton = ({
  onClick,
  disabled,
}: {
  onClick: () => void
  disabled: boolean
}) => (
  <button
    type="button"
    onClick={onClick}
    disabled={disabled}
    className="btn-primary btn-s"
  >
    <span>Submit</span>
    <div className="kb-shortcut">F3</div>
  </button>
)
