import React from 'react'
import { GraphicalIcon } from '../../common'

export const ResetButton = ({
  onClick,
}: {
  onClick: () => void
}): JSX.Element => {
  return (
    <button
      type="button"
      onClick={onClick}
      className="btn-m btn-link reset-btn"
    >
      <GraphicalIcon icon="reset" />
      <span>Reset Filters</span>
    </button>
  )
}
