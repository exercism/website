import React from 'react'
import pluralize from 'pluralize'
import { TrackProgressList } from '../../types'

export const ExercisesCompletedSummary = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  return (
    <div className="box">
      <div className="journey-h3">{tracks.numCompletedExercises}</div>
      <div className="journey-label">
        {pluralize('Exercise', tracks.numCompletedExercises)} completed
      </div>
    </div>
  )
}
