import React from 'react'
import { fromNow } from '@/utils/date'
import { GraphicalIcon, TrackIcon, Reputation } from '@/components/common'
import { missingExerciseIconErrorHandler } from '@/components/common/imageErrorHandler'
import { Contribution as ContributionProps } from '@/components/types'

export const Contribution = ({
  value,
  text,
  iconUrl,
  internalUrl,
  externalUrl,
  createdAt,
  track,
}: ContributionProps): JSX.Element => {
  const url = internalUrl || externalUrl
  const linkIcon = url === internalUrl ? 'chevron-right' : 'external-link'

  return (
    <a href={url} className="reputation-token">
      <img
        alt=""
        src={iconUrl}
        className="c-icon primary-icon"
        onError={missingExerciseIconErrorHandler}
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
          <time dateTime={createdAt}>{fromNow(createdAt)}</time>
        </div>
      </div>
      <Reputation value={`+ ${value}`} type="primary" />
      <GraphicalIcon icon={linkIcon} className="action-button" />
    </a>
  )
}
