import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, Icon } from '../common'
import pluralize from 'pluralize'

export type SolutionProps = {
  id: string
  exerciseIconName: string
  exerciseTitle: string
  trackIconName: string
  trackTitle: string
  status: string
  numIterations: number
  lines: string
  numViews: number
  submittedAt: string
  numStars: number
  numComments: number
}

export const Solution = ({
  exerciseIconName,
  exerciseTitle,
  trackIconName,
  trackTitle,
  status,
  numIterations,
  lines,
  numViews,
  submittedAt,
  numStars,
  numComments,
}: SolutionProps): JSX.Element => {
  return (
    <div className="solution">
      <div className="main">
        <div className="exercise">
          <GraphicalIcon icon={exerciseIconName} className="exercise-icon" />

          <div className="info">
            <div className="exercise-title">{exerciseTitle}</div>
            <div className="extra">
              <div className="track">
                in
                <Icon
                  icon={trackIconName}
                  className="c-track-icon"
                  alt={`icon for ${trackTitle} track`}
                />
                <div className="track-title">{trackTitle}</div>
              </div>
              <div className="status">
                {status === 'completed' ? (
                  <>
                    <GraphicalIcon icon="completed-check-circle" />
                    Completed
                  </>
                ) : null}
              </div>
            </div>
          </div>
        </div>
        <div className="stats">
          <div className="stat">
            <GraphicalIcon icon="iteration" />
            {numIterations} {pluralize('iteration', numIterations)}
          </div>
          <div className="stat">
            <GraphicalIcon icon="loc" />
            {lines} lines
          </div>
          <div className="stat">
            <GraphicalIcon icon="views" />
            {numViews} {pluralize('view', numViews)}
          </div>
        </div>
        <time dateTime={submittedAt}>
          Last submitted {fromNow(submittedAt)}
        </time>
      </div>
      <div className="counts">
        <div className="count">
          <GraphicalIcon icon="star" />
          <div className="num">{numStars}</div>
        </div>
        <div className="count">
          <GraphicalIcon icon="comment" />
          <div className="num">{numComments}</div>
        </div>
      </div>
    </div>
  )
}
