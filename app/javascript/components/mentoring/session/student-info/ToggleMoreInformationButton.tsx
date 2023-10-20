import React from 'react'
import { assembleClassNames } from '@/utils/assemble-classnames'
import Icon from '@/components/common/Icon'

export function ToggleMoreInformationButton({
  onClick,
  rotate,
}: {
  onClick: () => void
  rotate?: boolean
}) {
  return (
    <button
      className="self-stretch flex justify-center items-center mt-8 -mx-24 -mb-16 py-4 bg-backgroundColorD"
      onClick={onClick}
    >
      <Icon
        icon="chevron-down"
        alt="expand"
        height={16}
        width={16}
        className={assembleClassNames(
          rotate ? 'rotate-180' : '',
          'filter-textColor6'
        )}
      />
    </button>
  )
}
