// i18n-key-prefix: badgeSummary
// i18n-namespace: components/journey/overview/badges-section
import React from 'react'
import { BadgeList, BadgeRarity } from '../../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t, i18n } = useAppTranslation(
    'components/journey/overview/badges-section'
  )

  const parts = BADGE_RARITIES.map((rarity) => {
    const count = badges.filter(rarity).length
    return count > 0 ? t(`badgeSummary.rarity.${rarity}`, { count }) : null
  }).filter(Boolean) as string[]

  if (parts.length === 0) {
    return <p className="text-p-large">{t('badgeSummary.none')}</p>
  }

  const list = new Intl.ListFormat(i18n.language || 'en', {
    style: 'long',
    type: 'conjunction',
  }).format(parts)

  return <p className="text-p-large">{t('badgeSummary.summary', { list })}</p>
}
