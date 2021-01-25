import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, Reputation } from '../common'

export type ContributionProps = {
  id: string
  value: number
  description: string
  iconName: string
  internalLink?: string
  externalLink?: string
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
  const link = internalLink || externalLink
  const linkIcon = link === internalLink ? 'chevron-right' : 'external-link'

  return (
    <a href={link} className="reputation-token">
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
      <Reputation value={`+ ${value}`} type="primary" />
      <GraphicalIcon icon={linkIcon} className="action-button" />
    </a>
  )
}
