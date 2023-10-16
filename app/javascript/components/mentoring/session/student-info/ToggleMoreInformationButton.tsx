import Icon from '@/components/common/Icon'
import React from 'react'

export function ToggleMoreInformationButton({
  onClick,
  rotate,
}: {
  onClick: () => void
  rotate?: boolean
}) {
  return (
    <button className="self-center mt-8" onClick={onClick}>
      <Icon
        icon="chevron-down"
        alt="expand"
        height={16}
        width={16}
        className={rotate ? 'rotate-180' : ''}
      />
    </button>
  )
}
