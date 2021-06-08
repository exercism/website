import React from 'react'
import { GraphicalIcon } from '../common'
import { Badge as BadgeProps } from '../types'

export const RevealedBadge = ({
  badge,
}: {
  badge: BadgeProps
}): JSX.Element => {
  return (
    <div className="c-badge">
      <div className={`c-badge-medallion --${badge.rarity}`}>
        <GraphicalIcon icon={badge.iconName} />
      </div>
      <div className="--info">
        <div className="--name">{badge.name}</div>
        <div className="--desc">{badge.description}</div>
      </div>
    </div>
  )
}
