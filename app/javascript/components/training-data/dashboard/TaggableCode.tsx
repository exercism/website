import React from 'react'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '@/components/common'
import { TrainingData } from './Dashboard.types'

export const TaggableCode = ({ code }: { code: TrainingData }): JSX.Element => {
  return (
    <a className="--code-sample " href={code.links.edit}>
      <TrackIcon title={code.track.title} iconUrl={code.track.iconUrl} />
      <ExerciseIcon
        title={code.exercise.title}
        iconUrl={code.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--handle">{code.exercise.title}</div>
      </div>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
