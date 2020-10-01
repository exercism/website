import React from 'react'
import { TrackIcon } from '../../../common/TrackIcon'
import { ProgressBar } from './Track/ProgressBar'

export function Track({ track }) {
  return (
    <tr>
      <td>
        <TrackIcon track={track} />
      </td>
      <td>{track.title}</td>
      <td>{track.numConceptExercises}</td>
      <td>{track.numPracticeExercises}</td>
      <td>{track.webUrl}</td>
      <td>{track.isNew.toString()}</td>
      <td>{track.tags.join(', ')}</td>
      <td>{track.isJoined.toString()}</td>
      <td>{track.numCompletedConceptExercises}</td>
      <td>{track.numCompletedPracticeExercises}</td>
      <td>
        {track.isJoined && (
          <ProgressBar
            numConceptExercises={track.numConceptExercises}
            numPracticeExercises={track.numPracticeExercises}
            numCompletedConceptExercises={track.numCompletedConceptExercises}
            numCompletedPracticeExercises={track.numCompletedPracticeExercises}
          />
        )}
      </td>
    </tr>
  )
}
