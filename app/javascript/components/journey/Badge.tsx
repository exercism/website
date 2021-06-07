import React from 'react'
import { GraphicalIcon } from '../common'

type BadgeRarity = 'common' | 'rare' | 'ultimate' | 'legendary'

export type BadgeProps = {
  rarity: BadgeRarity
  iconName: string
  name: string
  description: string
  isRevealed: boolean
}

export const Badge = ({
  rarity,
  iconName,
  name,
  description,
  isRevealed,
}: BadgeProps): JSX.Element => {
  if (!isRevealed) {
    return <UnrevealedBadge rarity={rarity} />
  }

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

export const UnrevealedBadge = ({
  rarity,
}: {
  rarity: BadgeRarity
}): JSX.Element => {
  return (
    <div className="c-badge">
      <div className={`c-badge-medallion --${rarity} --unrevealed`}>
        <div className="--unknown">?</div>
      </div>
      <div className="--info">
        <div className="--name">Unrevealed</div>
        <div className="--desc">Click/tap to reveal</div>
      </div>
    </div>
  )
}
