import React from 'react'
import { fromNow } from '../../../utils/time'
import { TrackIcon } from '../../common/TrackIcon'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { Icon } from '../../common/Icon'

type SolutionProps = {
  trackTitle: string
  trackIconUrl: string
  menteeAvatarUrl: string
  menteeHandle: string
  exerciseTitle: string
  isStarred: boolean
  haveMentoredPreviously: boolean
  status: string
  updatedAt: string
  url: string
  showMoreInformation: (e: React.MouseEvent | React.FocusEvent) => void
  hideMoreInformation: () => void
}

export function Solution({
  trackTitle,
  trackIconUrl,
  menteeAvatarUrl,
  menteeHandle,
  exerciseTitle,
  isStarred,
  haveMentoredPreviously,
  status,
  updatedAt,
  url,
  showMoreInformation,
  hideMoreInformation,
}: SolutionProps) {
  return (
    <a
      href={url}
      className="--solution"
      onMouseEnter={showMoreInformation}
      onMouseLeave={hideMoreInformation}
      onFocus={showMoreInformation}
      onBlur={hideMoreInformation}
    >
      <TrackIcon title={trackTitle} iconUrl={trackIconUrl} />
      <div
        className="c-rounded-bg-img"
        style={{ backgroundImage: `url(${menteeAvatarUrl})` }}
      >
        <img
          src={menteeAvatarUrl}
          alt={`${menteeHandle}'s uploaded avatar`}
          className="tw-sr-only"
        />
      </div>
      <div className="--info">
        <div className="--handle">
          {menteeHandle}
          {isStarred ? <Icon icon="gold-star" alt="Starred student" /> : null}
          {haveMentoredPreviously ? <div className="dot" /> : null}
        </div>
        <div className="--exercise-title">on {exerciseTitle}</div>
      </div>
      <div className="--status">{status}</div>
      <time className="-updated-at">{fromNow(updatedAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
