import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, Icon, TrackIcon, ExerciseIcon } from '../common'
import pluralize from 'pluralize'

export type SolutionProps = {
  id: string
  url: string
  status: string
  numViews: number
  numStars: number
  numComments: number
  numIterations: number
  numLoc: string
  lastSubmittedAt: string
  exercise: {
    title: string
    iconUrl: string
  }
  track: {
    title: string
    iconUrl: string
  }
}

export const Solution = ({
  url,
  status,
  numViews,
  numStars,
  numComments,
  numIterations,
  numLoc,
  lastSubmittedAt,
  exercise,
  track,
}: SolutionProps): JSX.Element => {
  return (
    <a href={url} className="solution">
      <div className="main">
        <div className="exercise">
          <ExerciseIcon iconUrl={exercise.iconUrl} />
          <div className="info">
            <div className="exercise-title">{exercise.title}</div>
            <div className="extra">
              <div className="track">
                in
                <TrackIcon iconUrl={track.iconUrl} title={track.title} />
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
            {numLoc} lines
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
