import React, { useState } from 'react'
import { GraphicalIcon } from '../common'
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
        <div className={`c-badge-medallion --${badge.rarity}`}>
          <GraphicalIcon icon={badge.iconName} />
        </div>
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
