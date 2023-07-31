import React from 'react'
import pluralize from 'pluralize'
import { TrackIcon } from '../TrackIcon'
import { Exercise, Track, SolutionForStudent } from '../../types'
import { Icon, GraphicalIcon } from '../../common'
import { SolutionStatusTag } from './SolutionStatusTag'
import { ExerciseStatusTag } from './ExerciseStatusTag'
import { ExerciseTypeTag } from './ExerciseTypeTag'
import { Difficulty } from './Difficulty'
import { Outdated } from './info/Outdated'

export const Info = ({
  exercise,
  track,
  solution,
  renderBlurb,
  isSkinny,
}: {
  exercise: Exercise
  track?: Track
  solution?: SolutionForStudent
  renderBlurb: boolean
  isSkinny: boolean
}): JSX.Element => {
  return (
    <div className="--info">
      <div className="--title">
        {exercise.title}
        {track && !isSkinny ? (
          <div className="--track">
            in <TrackIcon iconUrl={track.iconUrl} title={track.title} />
            <div className="--track-title">{track.title}</div>
          </div>
        ) : null}
        {solution && solution.hasNotifications ? (
          <div className="c-notification-dot">
            <span className="sr-only">has notifications</span>
          </div>
        ) : null}

        {solution && solution.isOutOfDate ? <Outdated /> : null}
      </div>
      {isSkinny ? null : (
        <div className="--data">
          {solution ? (
            <SolutionStatusTag status={solution.status} size="small" />
          ) : (
            <ExerciseStatusTag exercise={exercise} size="small" />
          )}
          {solution ? null : exercise.type == 'practice' ? (
            <Difficulty difficulty={exercise.difficulty} size="small" />
          ) : (
            <ExerciseTypeTag type={exercise.type} size="small" />
          )}

          {solution && solution.mentoringStatus == 'requested' ? (
            <Icon
              icon="mentoring-status-requested"
              alt="Mentoring requested"
              className="--mentoring-status"
            />
          ) : solution && solution.mentoringStatus == 'in_progress' ? (
            <Icon
              icon="mentoring-status-in-progress"
              alt="Mentoring in progress"
              className="--mentoring-status"
            />
          ) : solution && solution.mentoringStatus == 'finished' ? (
            <Icon
              icon="mentoring-status-finished"
              alt="Mentoring finished"
              className="--mentoring-status"
            />
          ) : null}

          {solution && solution.numIterations > 0 ? (
            <div className="--iterations-count">
              <GraphicalIcon icon="iteration" />
              {solution.numIterations}{' '}
              {pluralize('iteration', solution.numIterations)}
            </div>
          ) : null}
        </div>
      )}
      {renderBlurb && !isSkinny ? (
        <div className="--blurb">{exercise.blurb}</div>
      ) : null}
    </div>
  )
}
