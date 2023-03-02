import React from 'react'
import { PullRequestWidget } from './PullRequestWidget'
import { ExerciseWidget } from '../ExerciseWidget'
import { ConceptWidget } from '../ConceptWidget'
import type {
  SiteUpdate as SiteUpdateProps,
  SiteUpdateExpandedInfo,
} from '@/components/types'

export const ExpandedInfo = ({
  expanded,
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
        <div className="info">
          <div className="title">{expanded.title}</div>
          <div className="byline">
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
