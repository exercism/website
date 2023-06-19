import React from 'react'
import { PullRequestWidget } from './PullRequestWidget'
import { ExerciseWidget } from '../ExerciseWidget'
import { ConceptWidget } from '../ConceptWidget'
import { HandleWithFlair } from '../HandleWithFlair'
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
            <div className="by flex">
              by&nbsp;
              <strong>
                <HandleWithFlair
                  handle={expanded.author.handle}
                  flair={expanded.author.flair}
                  size="medium"
                />
              </strong>
            </div>
          </div>
        </div>
      </div>
      {expanded.descriptionHtml && (
        <div
          className="description c-highlight-links"
          dangerouslySetInnerHTML={{ __html: expanded.descriptionHtml }}
        />
      )}
      {pullRequest ? <PullRequestWidget {...pullRequest} /> : null}
      {conceptWidget ? <ConceptWidget {...conceptWidget} /> : null}
      {exerciseWidget ? (
        <ExerciseWidget {...exerciseWidget} renderBlurb={false} />
      ) : null}
    </div>
  )
}
