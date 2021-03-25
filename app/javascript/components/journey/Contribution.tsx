import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, TrackIcon, Reputation } from '../common'

export type ContributionProps = {
  id: string
  value: number
  text: string
  iconUrl: string
  internalLink?: string
  externalLink?: string
  awardedAt: string
  track?: {
    title: string
    iconUrl: string
  }
}

export const Contribution = ({
  value,
  text,
  iconUrl,
  internalLink,
  externalLink,
  awardedAt,
  track,
}: ContributionProps): JSX.Element => {
  const link = internalLink || externalLink
  const linkIcon = link === internalLink ? 'chevron-right' : 'external-link'

  return (
    <a href={link} className="reputation-token">
      <img src={iconUrl} className="c-icon primary-icon" />
      <div className="info">
        <div className="title" dangerouslySetInnerHTML={{ __html: text }} />
        <div className="extra">
          {track ? (
            <div className="exercise">
              in
              <TrackIcon
                iconUrl={track.iconUrl}
                title={track.title}
                className="primary-icon"
              />
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
