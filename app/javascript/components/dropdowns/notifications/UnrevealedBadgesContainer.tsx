import React from 'react'
import { UnrevealedBadge } from './types'
import { GraphicalIcon } from '../../common/GraphicalIcon'

export const UnrevealedBadgesContainer = ({
  badges,
  url,
}: {
  badges: UnrevealedBadge[]
  url: string
}): JSX.Element | null => {
  switch (badges.length) {
    case 0:
      return null
    case 1:
      return <SingleUnrevealedBadge badge={badges[0]} url={url} />
    default:
      return <MultipleUnrevealedBadges badges={badges} url={url} />
  }
}

const SingleUnrevealedBadge = ({
  badge,
  url,
}: {
  badge: UnrevealedBadge
  url: string
}) => {
  return (
    <a href={url} className="unrevealed-badge">
      <BadgeMedallion badge={badge} />
      <div className="text">You&apos;ve earned a new badge!</div>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}

const MultipleUnrevealedBadges = ({
  badges,
  url,
}: {
  badges: UnrevealedBadge[]
  url: string
}) => {
  return (
    <a href={url} className="unrevealed-badges">
      <div className="content">
        <div className="text">You&apos;ve earned new badges!</div>
        <div className="medallions">
          {badges.map((badge, i) => (
            <BadgeMedallion key={i} badge={badge} />
          ))}
        </div>
      </div>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}

const BadgeMedallion = ({ badge }: { badge: UnrevealedBadge }) => {
  const classNames = [`--${badge.rarity}`, 'c-badge-medallion']

  return <div className={classNames.join(' ')} />
}
