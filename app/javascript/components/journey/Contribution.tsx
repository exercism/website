import React from 'react'
import { fromNow } from '../../utils/date'
import { imageErrorHandler, Icon, TrackIcon, Reputation } from '../common'
import { Contribution as ContributionProps } from '../types'

export const Contribution = ({
  value,
  text,
  iconUrl,
  internalUrl,
  externalUrl,
  earnedOn,
  track,
}: ContributionProps): JSX.Element => {
  const url = internalUrl || externalUrl

  let linkIcon

  if (internalUrl) {
    linkIcon = (
      <Icon icon="chevron-right" className="action-button" alt="Open link" />
    )
  } else if (externalUrl) {
    linkIcon = (
      <Icon icon="external-link" className="action-button" alt="Open link" />
    )
  } else {
    linkIcon = <span className="action-button" />
  }

  return (
    <a href={url} className="reputation-token">
      <img
        alt=""
        role="presentation"
        src={iconUrl}
        className="c-icon primary-icon"
        onError={imageErrorHandler}
      />
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
          <time dateTime={earnedOn}>{fromNow(earnedOn)}</time>
        </div>
      </div>
      <Reputation value={`+ ${value}`} type="primary" />
      {linkIcon}
    </a>
  )
}
