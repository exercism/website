import pluralize from 'pluralize'
import React from 'react'
import { BadgeList, BadgeRarity } from '../../../types'
import { toSentence } from '../../../../utils/toSentence'

const BADGE_RARITIES: BadgeRarity[] = [
  'legendary',
  'ultimate',
  'rare',
  'common',
]

export const BadgeSummary = ({
  badges,
}: {
  badges: BadgeList
}): JSX.Element => {
  const parts = BADGE_RARITIES.map<string>((rarity: BadgeRarity) => {
    const badgesWithRarity = badges.filter(rarity)

    return badgesWithRarity.length > 0
      ? `${badgesWithRarity.length} ${rarity} ${pluralize(
          'badge',
          badgesWithRarity.length
        )}`
      : ''
  }).filter((part) => part.length > 0)

  return (
    <p className="text-p-large">
      You have {parts.length == 0 ? 'no badges' : toSentence(parts)}.
    </p>
  )
}
