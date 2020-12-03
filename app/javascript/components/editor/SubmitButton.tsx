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
    className="btn-small-cta"
  >
    Submit
    <div className="kb-shortcut">F3</div>
  </button>
)
