import React from 'react'
import { fromNow } from '@/utils/date'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '@/components/common'
import { SolutionProps } from '@/components/journey/Solution'
import { TrainingData } from './Dashboard.types'

export const TaggableCode = ({ code }: { code: TrainingData }): JSX.Element => {
  return (
    <a className="--solution" href={code.links.self}>
      <TrackIcon title={code.track.title} iconUrl={code.track.iconUrl} />
      <ExerciseIcon
        title={code.exercise.title}
        iconUrl={code.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--handle">{code.exercise.title}</div>
      </div>
      <time className="-updated-at">{fromNow(code.createdAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}