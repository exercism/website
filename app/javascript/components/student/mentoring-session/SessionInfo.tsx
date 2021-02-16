import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { ExerciseIcon } from '../../common/ExerciseIcon'
import { Partner, Track, Exercise } from '../../mentoring/Session'

export const SessionInfo = ({
  mentor,
  track,
  exercise,
}: {
  mentor: Partner
  track: Track
  exercise: Exercise
}): JSX.Element => {
  return (
    <>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <ExerciseIcon icon={exercise.iconName} />
      <div className="info-for-student">
        You&apos;re being mentored by <strong>{mentor.handle}</strong> on
        <div className="exercise-title">{exercise.title}</div>
      </div>
    </>
  )
}
