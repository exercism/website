import pluralize from 'pluralize'
import React from 'react'
import { TrackProgressList } from '../../types'

export const LearningOverview = ({
  tracks,
}: {
  tracks: TrackProgressList
}): JSX.Element => {
  return (
    <div className="overview">
      <h3>
        You&apos;re{' '}
        <em className="text-gradient">{tracks.completion.toFixed(2)}%</em>{' '}
        through your enrolled {pluralize('Track', tracks.length)}.{' '}
        {tracks.completion > 1 ? <strong>Keep it up! 🚀</strong> : null}
      </h3>
      <div className="c-progress --large">
        <div className="bar" style={{ width: `${tracks.completion}%` }} />
      </div>
      <div className="count">
        {tracks.numCompletedExercises} / {tracks.numExercises} exercises
        completed
      </div>
    </div>
  )
}
