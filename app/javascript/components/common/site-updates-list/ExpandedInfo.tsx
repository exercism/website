import React from 'react'
import { Avatar } from '../Avatar'
import {
  SiteUpdate as SiteUpdateProps,
  SiteUpdateExpandedInfo,
} from '../../types'
import { SiteUpdateIcon } from './SiteUpdateIcon'
import { PullRequestWidget } from './PullRequestWidget'
import { ExerciseWidget } from '../ExerciseWidget'
import { ConceptWidget } from '../ConceptWidget'

export const ExpandedInfo = ({
  expanded,
  icon,
  track,
  pullRequest,
  conceptWidget,
  exerciseWidget,
}: Pick<
  SiteUpdateProps,
  'icon' | 'track' | 'pullRequest' | 'conceptWidget' | 'exerciseWidget'
> & {
  expanded: SiteUpdateExpandedInfo
}): JSX.Element => {
  return (
    <div className="expanded">
      <div className="header">
        <SiteUpdateIcon icon={icon} context="update" track={track} />
        <div className="info">
          <div className="title">{expanded.title}</div>
          <div className="byline">
            <Avatar
              src={expanded.author.avatarUrl}
              handle={expanded.author.handle}
            />
            <div className="by">
              by <strong>{expanded.author.handle}</strong>
            </div>
          </div>
        </div>
      </div>
      <div className="description">{expanded.description}</div>
      {pullRequest ? <PullRequestWidget {...pullRequest} /> : null}
      {conceptWidget ? <ConceptWidget {...conceptWidget} /> : null}
      {exerciseWidget ? (
        <ExerciseWidget {...exerciseWidget} renderBlurb={false} />
      ) : null}
    </div>
  )
}
