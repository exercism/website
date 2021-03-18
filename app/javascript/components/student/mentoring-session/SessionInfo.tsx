import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { ExerciseIcon } from '../../common/ExerciseIcon'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'
import { Mentor } from '../MentoringSession'

export const SessionInfo = ({
  mentor,
  track,
  exercise,
}: {
  mentor?: Mentor
  track: Track
  exercise: Exercise
}): JSX.Element => {
  return (
    <>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <ExerciseIcon iconUrl={exercise.iconUrl} />
      <div className="info-for-student">
        {mentor ? (
          <React.Fragment>
            You&apos;re being mentored by <strong>{mentor.handle}</strong> on{' '}
            <div className="exercise-title">{exercise.title}</div>
          </React.Fragment>
        ) : (
          /*TODO: What should the title show when there is no mentor yet? */
          <React.Fragment>
            Get mentoring on
            <div className="exercise-title">{exercise.title}</div>
          </React.Fragment>
        )}
      </div>
    </>
  )
}
