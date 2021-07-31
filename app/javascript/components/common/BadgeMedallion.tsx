import React from 'react'
import { Badge } from '../types'
import { GraphicalIcon } from './'

export const BadgeMedallion = ({
  badge,
}: {
  badge: Pick<Badge, 'rarity' | 'iconName'>
}): JSX.Element => {
  const classNames = ['c-badge-medallion', `--${badge.rarity}`]

  return (
    <div className={classNames.join(' ')}>
      <GraphicalIcon icon={badge.iconName} />
    </div>
  )
}
