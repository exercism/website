import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, Icon } from '../common'
import pluralize from 'pluralize'

export type SolutionProps = {
  id: string
  url: string
  status: string
  numViews: number
  numStars: number
  numComments: number
  numIterations: number
  numLocs: string
  lastSubmittedAt: string
  exercise: {
    title: string
    iconName: string
  }
  track: {
    title: string
    iconName: string
  }
}

export const Solution = ({
  url,
  status,
  numViews,
  numStars,
  numComments,
  numIterations,
  numLocs,
  lastSubmittedAt,
  exercise,
  track,
}: SolutionProps): JSX.Element => {
  return (
    <a href={url} className="solution">
      <div className="main">
        <div className="exercise">
          <GraphicalIcon icon={exercise.iconName} className="c-exercise-icon" />
          <div className="info">
            <div className="exercise-title">{exercise.title}</div>
            <div className="extra">
              <div className="track">
                in
                <Icon
                  icon={track.iconName}
                  className="c-track-icon"
                  alt={`icon for ${track.title} track`}
                />
                <div className="track-title">{track.title}</div>
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
            {numLocs} lines
          </div>
          <div className="stat">
            <GraphicalIcon icon="views" />
            {numViews} {pluralize('view', numViews)}
          </div>
        </div>
        <time dateTime={lastSubmittedAt}>
          Last submitted {fromNow(lastSubmittedAt)}
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
    </a>
  )
}
