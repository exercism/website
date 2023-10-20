import React from 'react'
import Icon from '@/components/common/Icon'

export function SessionInfoHamburgerButton({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  return (
    <button
      className="btn-s btn-default download-btn"
      type="button"
      onClick={onClick}
    >
      <Icon icon="hamburger" alt="Download solution" />
    </button>
  )
}
