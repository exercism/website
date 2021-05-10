import React from 'react'
import { GraphicalIcon } from '../common'

type BadgeRarity = 'common' | 'rare' | 'ultimate' | 'legendary'

export type BadgeProps = {
  rarity: BadgeRarity
  iconName: string
  name: string
  description: string
}

export const Badge = ({
  rarity,
  iconName,
  name,
  description,
}: BadgeProps): JSX.Element => {
  return (
    <div className="c-badge">
      <div className={`c-badge-medallion --${rarity}`}>
        <GraphicalIcon icon={iconName} />
      </div>
      <div className="--info">
        <div className="--name">{name}</div>
        <div className="--desc">{description}</div>
      </div>
    </div>
  )
}
