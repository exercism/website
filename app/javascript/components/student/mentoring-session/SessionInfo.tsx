import React from 'react'
import { TrackIcon, ExerciseIcon, HandleWithFlair } from '@/components/common'
import { Mentor } from '../MentoringSession'
import type {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '@/components/types'

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
            <div className="flex items-center">
              You&apos;re being mentored by&nbsp;
              <strong className="flex">
                {
                  <HandleWithFlair
                    handle={mentor.handle}
                    flair={mentor.flair}
                    size="small"
                  />
                }
                &nbsp;
              </strong>
              on
            </div>{' '}
            <div className="exercise-title">{exercise.title}</div>
          </React.Fragment>
        ) : (
          <React.Fragment>
            Get mentoring on
            <div className="exercise-title">{exercise.title}</div>
          </React.Fragment>
        )}
      </div>
    </>
  )
}
