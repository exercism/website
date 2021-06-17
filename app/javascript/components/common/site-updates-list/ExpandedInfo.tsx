import React from 'react'
import { Avatar } from '../Avatar'
import {
  SiteUpdate as SiteUpdateProps,
  SiteUpdateExpandedInfo,
} from '../../types'
import { PullRequestWidget } from './PullRequestWidget'
import { ExerciseWidget } from '../ExerciseWidget'
import { ConceptWidget } from '../ConceptWidget'

export const ExpandedInfo = ({
  expanded,
  pullRequest,
  conceptWidget,
  exerciseWidget,
  IconComponent,
}: Pick<SiteUpdateProps, 'pullRequest' | 'conceptWidget' | 'exerciseWidget'> & {
  expanded: SiteUpdateExpandedInfo
  IconComponent: React.ComponentType<{}>
}): JSX.Element => {
  return (
    <div className="expanded">
      <div className="header">
        <IconComponent />
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
