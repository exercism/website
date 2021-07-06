import React from 'react'
import { ProminentLink } from '../../common'
import { BadgeMedallion } from '../../common/BadgeMedallion'
import { BadgeList } from '../../types'
import { BadgeSummary } from './badges-section/BadgeSummary'

export type Props = {
  badges: BadgeList
  links: Links
}

type Links = {
  badges: string
}

const MAX_BADGES = 4

export const BadgesSection = ({ badges, links }: Props): JSX.Element => {
  const badgesToShow = badges.sort().items.slice(0, MAX_BADGES)

  return (
    <section className="badges-section">
      <div className="info">
        <div className="journey-h3">A glimpse of your badges collection</div>
        <BadgeSummary badges={badges} />
        <ProminentLink
          link={links.badges}
          text="See your entire badge collection"
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
