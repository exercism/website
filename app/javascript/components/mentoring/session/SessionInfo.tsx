import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { Avatar } from '../../common/Avatar'
import { Student } from '../../types'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'
import { Links } from '../Session'

export const SessionInfo = ({
  student,
  track,
  exercise,
  links,
}: {
  student: Student
  track: Track
  exercise: Exercise
  links: Links
}): JSX.Element => {
  return (
    <>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <div className="student">
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="info">
          <div className="handle">{student.handle}</div>
          <div className="exercise">
            on{' '}
            <a
              href={links.exercise}
              className="hover:text-prominentLinkColor font-semibold"
            >
              {exercise.title}
            </a>{' '}
            in {track.title}{' '}
          </div>
        </div>
      </div>
    </>
  )
}
