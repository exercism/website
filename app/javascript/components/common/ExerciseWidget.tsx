import React, { forwardRef } from 'react'
import { Track, Exercise, SolutionForStudent } from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Info } from './exercise-widget/Info'
import { ExerciseTooltip } from '../tooltips'
import { ExercismTippy } from '../misc/ExercismTippy'

type Links = {
  tooltip?: string
}

export type Props = {
  exercise: Exercise
  track?: Track
  solution?: SolutionForStudent
  links?: Links
  renderBlurb: boolean
  isSkinny: boolean
}

export function ExerciseWidget({
  exercise,
  track,
  solution,
  links = {},
  renderBlurb,
  isSkinny,
}: Props): JSX.Element {
  return (
    <ExercismTippy
      content={
        links.tooltip ? <ExerciseTooltip endpoint={links.tooltip} /> : null
      }
      disabled={!links.tooltip}
    >
      <ReferenceElement
        exercise={exercise}
        track={track}
        solution={solution}
        renderBlurb={renderBlurb}
        isSkinny={isSkinny}
      />
    </ExercismTippy>
  )
}

const ReferenceElement = forwardRef<
  HTMLElement,
  Omit<Props, 'links'> & {
    onMouseEnter?: () => void
    onMouseLeave?: () => void
  }
>(({ exercise, track, solution, renderBlurb, isSkinny, ...props }, ref) => {
  const info = (
    <Info
      exercise={exercise}
      solution={solution}
      track={track}
      renderBlurb={renderBlurb}
      isSkinny={isSkinny}
    />
  )
  const classNames = [
    'c-exercise-widget',
    `--${
      solution ? solution.status : exercise.isUnlocked ? 'available' : 'locked'
    }`,
    exercise.isRecommended ? '--recommended' : '',
    '--interactive',
    isSkinny ? '--skinny' : '',
  ]
    .filter((name) => name.length > 0)
    .join(' ')

  const url = solution ? solution.privateUrl : exercise.links.self

  return (
    <a
      ref={ref as React.RefObject<HTMLAnchorElement>}
      href={url}
      className={classNames}
      {...props}
    >
      <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
      {info}
      <GraphicalIcon
        icon={exercise.isUnlocked ? 'chevron-right' : 'lock'}
        className="--action-icon sm:block hidden"
      />
    </a>
  )
})

ExerciseWidget.defaultProps = {
  renderAsLink: true,
  renderBlurb: true,
  isSkinny: false,
}
export default ExerciseWidget
