import React from 'react'
import { TrackProgressList } from '../../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const ExercisesCompletedSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/journey/overview/learning-section'
  )

  return (
    <div className="box">
      <div className="journey-h3">{tracks.numCompletedExercises}</div>
      <div className="journey-label">
        {t(
          tracks.numCompletedExercises > 1
            ? 'exercisesCompletedSummary.exercisesCompleted'
            : 'exercisesCompletedSummary.exerciseCompleted',
          {
            count: tracks.numCompletedExercises,
          }
        )}{' '}
      </div>
    </div>
  )
}
