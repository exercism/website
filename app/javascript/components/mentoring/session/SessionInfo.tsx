import { useAppTranslation } from '@/i18n/useAppTranslation'
import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { Avatar } from '../../common/Avatar'
import { Student } from '../../types'
import {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
} from '../../types'
import { Links } from '../Session'
import { Trans } from 'react-i18next'

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
  const { t } = useAppTranslation()

  return (
    <>
      <TrackIcon title={track.title} iconUrl={track.iconUrl} />
      <div className="student">
        <Avatar src={student.avatarUrl} handle={student.handle} />
        <div className="info">
          <div className="handle">{student.handle}</div>
          <div className="exercise">
            <Trans
              i18nKey="exerciseInTrack"
              values={{
                exerciseTitle: exercise.title,
                trackTitle: track.title,
              }}
              components={{
                a: (
                  <a
                    href={links.exercise}
                    className="hover:text-prominentLinkColor font-semibold"
                  />
                ),
              }}
            />
          </div>
        </div>
      </div>
    </>
  )
}
