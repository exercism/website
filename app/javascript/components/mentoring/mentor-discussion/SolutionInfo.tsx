import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { Avatar } from '../../common/Avatar'
import { Student, Track, Exercise } from '../MentorDiscussion'

export const SolutionInfo = ({
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
