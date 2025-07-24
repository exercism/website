import React from 'react'
import { TrackIcon, ExerciseIcon, HandleWithFlair } from '@/components/common'
import { Mentor } from '../MentoringSession'
import type {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export const SessionInfo = ({
  mentor,
  track,
  exercise,
}: {
  mentor?: Mentor
  track: Track
  exercise: Exercise
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/mentoring-session')
  return (
    <>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <ExerciseIcon iconUrl={exercise.iconUrl} />
      <div className="info-for-student">
        {mentor ? (
          <React.Fragment>
            <Trans
              ns="components/student/mentoring-session"
              i18nKey="sessionInfo.youreBeingMentoredByOn"
              values={{ exerciseTitle: exercise.title }}
              components={{
                handleWithFlair: (
                  <strong className="flex">
                    &nbsp;
                    <HandleWithFlair
                      handle={mentor.handle}
                      flair={mentor.flair}
                      size="small"
                    />
                    &nbsp;
                  </strong>
                ),
                divFlex: <div className="flex items-center" />,
                divExerciseTitle: <div className="exercise-title" />,
              }}
            />
          </React.Fragment>
        ) : (
          <React.Fragment>
            <Trans
              i18nKey="sessionInfo.getMentoringOn"
              ns="components/student/mentoring-session"
              values={{ exerciseTitle: exercise.title }}
              components={{
                divExerciseTitle: <div className="exercise-title" />,
              }}
            />
          </React.Fragment>
        )}
      </div>
    </>
  )
}
