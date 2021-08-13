import React, { useState } from 'react'
import { BadgeMedallion } from '../common/BadgeMedallion'
import { Badge as BadgeProps } from '../types'
import { BadgeModal } from '../modals/BadgeModal'

export const RevealedBadge = ({
  badge,
}: {
  badge: BadgeProps
}): JSX.Element => {
  const [open, setOpen] = useState(false)
  return (
    <React.Fragment>
      <button className="c-badge" onClick={() => setOpen(!open)}>
        <BadgeMedallion badge={badge} />
        <div className="--info">
          <div className="--name">{badge.name}</div>
          <div className="--desc">{badge.description}</div>
        </div>
      </button>
      <BadgeModal
        badge={badge}
        open={open}
        onClose={() => {
          setOpen(false)
        }}
      />
    </React.Fragment>
  )
}
