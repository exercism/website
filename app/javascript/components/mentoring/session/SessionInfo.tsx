import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { Avatar } from '../../common/Avatar'
import { Student } from '../Session'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'

export const SessionInfo = ({
  student,
  track,
  exercise,
}: {
  student: Student
  track: Track
  exercise: Exercise
}): JSX.Element => {
  return (
    <>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <div className="student">
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="info">
          <div className="handle">{student.handle}</div>
          <div className="exercise">
            on {exercise.title} in {track.title}{' '}
          </div>
        </div>
      </div>
    </>
  )
}
