import React from 'react'
import { Icon } from '../../common'

export const CloseButton = ({
  onClick,
}: {
  onClick: () => void
}): JSX.Element => {
  return (
    <button type="button" className="close-btn" onClick={onClick}>
      <Icon icon="close" alt="Close the modal" className="filter-textColor6" />
    </button>
  )
}
