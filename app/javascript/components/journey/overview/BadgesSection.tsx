import React from 'react'
import { ProminentLink } from '../../common'
import { BadgeMedallion } from '../../common/BadgeMedallion'
import { BadgeList } from '../../types'
import { BadgeSummary } from './badges-section/BadgeSummary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Props = {
  badges: BadgeList
  links: Links
}

type Links = {
  badges: string
}

const MAX_BADGES = 4

export const BadgesSection = ({ badges, links }: Props): JSX.Element => {
  const { t } = useAppTranslation('components/journey/overview')
  const badgesToShow = badges.sort().items.slice(0, MAX_BADGES)

  return (
    <section className="badges-section">
      <div className="info">
        <div className="journey-h3">{t('badgesSection.aGlimpseOfBadges')}</div>
        <BadgeSummary badges={badges} />
        <ProminentLink
          link={links.badges}
          text={t('badgesSection.seeEntireBadgeCollection')}
          withBg
        />
      </div>
      <div className="badges">
        {badgesToShow.map((badge) => (
          <BadgeMedallion key={badge.uuid} badge={badge} />
        ))}
      </div>
    </section>
  )
}
