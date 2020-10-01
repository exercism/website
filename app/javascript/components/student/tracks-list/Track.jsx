import React from 'react'
import { TrackIcon } from '../../common/TrackIcon'
import { ProgressBar } from './ProgressBar'

export function Track({ track }) {
  return (
    <a className="c-track" href={track.webUrl}>
      <TrackIcon track={track} />
      <div className="info">
        <h3 className="title">{track.title}</h3>
        <ul className="counts">
          <li>{track.numConceptExercises} concepts</li>
          <li>{track.numPracticeExercises} exercises</li>
        </ul>
      </div>
    </a>
  )
}
