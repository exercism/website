import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, Icon } from '../common'
import pluralize from 'pluralize'

export type ContributionProps = {
  id: string
  value: number
  description: string
  iconName: string
  internalLink: string
  externalLink: string
  awardedAt: string
  track?: {
    title: string
    iconName: string
  }
}

export const Contribution = ({
  value,
  description,
  iconName,
  internalLink,
  externalLink,
  awardedAt,
  track,
}: ContributionProps): JSX.Element => {
  return (
    <a href={externalLink} className="reputation-token">
      <GraphicalIcon icon={iconName} className="primary-icon" />
      <div className="info">
        <div className="title">{description}</div>
        <div className="extra">
          {track ? (
            <div className="exercise">
              in
              <GraphicalIcon icon={track.iconName} className="primary-icon" />
              <div className="name">{track.title}</div>
            </div>
          ) : (
            <div className="generic">Generic</div>
          )}
          <time dateTime={awardedAt}>{fromNow(awardedAt)}</time>
        </div>
      </div>
      <div className="c-primary-reputation" aria-label={`+${value} reputation`}>
        <div className="--inner">
          <Icon icon="reputation" alt="Reputation" />
          <span>+ {value}</span>
        </div>
      </div>
      <GraphicalIcon icon="chevron-right" className="action-button" />
    </a>
  )
}
