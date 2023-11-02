import React from 'react'
import { fromNow } from '@/utils/date'
import { TrackIcon, ExerciseIcon, GraphicalIcon } from '@/components/common'
import { SolutionProps } from '@/components/journey/Solution'

export const TaggableSolution = ({
  solution,
}: {
  solution: SolutionProps & { links: { self: string } }
}): JSX.Element => {
  return (
    <a className="--solution" href={solution.links.self}>
      <TrackIcon
        title={solution.track.title}
        iconUrl={solution.track.iconUrl}
      />
      <ExerciseIcon
        title={solution.exercise.title}
        iconUrl={solution.exercise.iconUrl}
      />
      <div className="--info">
        <div className="--handle">{solution.exercise.title}</div>
      </div>
      <time className="-updated-at">{fromNow(solution.lastIteratedAt)}</time>
      <GraphicalIcon icon="chevron-right" className="action-icon" />
    </a>
  )
}
