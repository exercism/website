import React, { forwardRef } from 'react'
import { Icon } from '../../common/Icon'

type ReputationIconProps = {
  reputation: number
  isSeen: boolean
}

export const ReputationIcon = forwardRef<
  HTMLButtonElement,
  ReputationIconProps
>((props, ref) => {
  const { reputation, isSeen, ...buttonProps } = props

  return (
    <button
      ref={ref}
      className="c-primary-reputation"
      aria-label={`${reputation} reputation`}
      {...buttonProps}
    >
      <div className="--inner">
        <Icon icon="reputation" alt="Reputation" />
        <span>{reputation}</span>
      </div>
      {isSeen ? null : <div className="--notification" />}
    </button>
  )
})
