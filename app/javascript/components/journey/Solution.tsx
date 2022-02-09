import React from 'react'
import { fromNow } from '../../utils/time'
import { GraphicalIcon, TrackIcon, ExerciseIcon, Icon } from '../common'
import { GenericTooltip } from '../misc/ExercismTippy'
import pluralize from 'pluralize'

export type SolutionProps = {
  uuid: string
  privateUrl: string
  status: string
  publishedIterationHeadTestsStatus: string
  numViews?: number
  numStars: number
  numComments: number
  numIterations: number
  numLoc?: string
  lastIteratedAt: string
  isOutOfDate: boolean
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
  privateUrl,
  status,
  publishedIterationHeadTestsStatus,
  numViews,
  numStars,
  numComments,
  numIterations,
  numLoc,
  lastIteratedAt,
  exercise,
  track,
  isOutOfDate,
}: SolutionProps): JSX.Element => {
  return (
    <a href={privateUrl} className="solution">
      <div className="main">
        <div className="exercise">
          <ExerciseIcon iconUrl={exercise.iconUrl} />
          <div className="info">
            <div className="flex items-center mb-8">
              <div className="exercise-title">{exercise.title}</div>

              {isOutOfDate ? (
                <GenericTooltip content="There is a newer version of this exercise. Visit the exercise page to upgrade to the latest version.">
                  <div>
                    <Icon
                      icon="warning"
                      alt="There is a newer version of this exercise. Visit the exercise page to upgrade."
                      className="--out-of-date"
                    />
                  </div>
                </GenericTooltip>
              ) : null}

              {publishedIterationHeadTestsStatus === 'passed' ? (
                <Icon
                  icon="golden-check"
                  alt="Passes tests of the latest version of the exercise"
                  className="head-tests-status --passed"
                />
              ) : publishedIterationHeadTestsStatus === 'failed' ||
                publishedIterationHeadTestsStatus === 'errored' ? (
                <GenericTooltip content="This solution fails the tests of the latest version of this exercise. Try updating the exercise and checking it locally or in the online editor.">
                  <div>
                    <Icon
                      icon="cross-circle"
                      alt="Failed tests of the latest version of the exercise"
                      className="head-tests-status --failed"
                    />
                  </div>
                </GenericTooltip>
              ) : null}
            </div>
            <div className="extra">
              <div className="track">
                in
                <TrackIcon iconUrl={track.iconUrl} title={track.title} />
                <div className="track-title">{track.title}</div>
              </div>
              {status === 'completed' ? (
                <div className="status">
                  <GraphicalIcon icon="completed-check-circle" />
                  Completed
                </div>
              ) : status === 'published' ? (
                <div className="status">
                  <GraphicalIcon icon="completed-check-circle" />
                  Published
                </div>
              ) : (
                <></>
              )}
            </div>
          </div>
        </div>
        <div className="stats">
          <div className="stat">
            <GraphicalIcon icon="iteration" />
            {numIterations} {pluralize('iteration', numIterations)}
          </div>
          {numLoc ? (
            <div className="stat">
              <GraphicalIcon icon="loc" />
              {numLoc} lines
            </div>
          ) : null}
          {numViews ? (
            <div className="stat">
              <GraphicalIcon icon="views" />
              {numViews} {pluralize('view', numViews)}
            </div>
          ) : null}
        </div>
        {lastIteratedAt ? (
          <time className="iterated-at" dateTime={lastIteratedAt}>
            Last submitted {fromNow(lastIteratedAt)}
          </time>
        ) : null}
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
