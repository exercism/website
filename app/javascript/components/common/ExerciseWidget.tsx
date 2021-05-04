import React, { forwardRef } from 'react'
import { Track, Exercise, SolutionForStudent } from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Info } from './exercise-widget/Info'
import { usePanel } from '../../hooks/use-panel'
import { ExerciseTooltip } from '../tooltips/ExerciseTooltip'

type Size = 'tiny' | 'small' | 'medium' | 'large' | 'tooltip'

type Links = {
  tooltip: string
}

type Props = {
  exercise: Exercise
  track: Track
  solution?: SolutionForStudent
  size: Size
  links?: Links
}

export const ExerciseWidget = ({
  exercise,
  track,
  solution,
  size,
  links,
}: Props): JSX.Element => {
  const { open, setOpen, buttonAttributes, panelAttributes } = usePanel({
    placement: 'right-start',
    modifiers: [
      {
        name: 'offset',
        options: {
          offset: [0, 8],
        },
      },
    ],
  })
  const mouseEvents = links
    ? {
        onMouseEnter: () => setOpen(true),
        onMouseLeave: () => setOpen(false),
      }
    : {}

  return (
    <React.Fragment>
      <ReferenceElement
        exercise={exercise}
        track={track}
        solution={solution}
        size={size}
        {...buttonAttributes}
        {...mouseEvents}
      />
      {open && links ? (
        <ExerciseTooltip
          slug={exercise.slug}
          endpoint={links.tooltip}
          {...panelAttributes}
        />
      ) : null}
    </React.Fragment>
  )
}

const ReferenceElement = forwardRef<
  HTMLElement,
  Omit<Props, 'links'> & {
    onMouseEnter?: () => void
    onMouseLeave?: () => void
  }
>(({ exercise, track, solution, size, ...props }, ref) => {
  if (solution) {
    return (
      <a
        ref={ref as React.RefObject<HTMLAnchorElement>}
        href={solution.url}
        className={`c-exercise-widget --${solution.status} --${size}`}
        {...props}
      >
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} track={track} />
        <GraphicalIcon icon="chevron-right" className="--action-icon" />
      </a>
    )
  } else if (exercise.isUnlocked) {
    const classNames = [
      'c-exercise-widget',
      '--available',
      `--${size}`,
      exercise.isRecommended ? '--recommended' : '',
    ].filter((name) => name.length > 0)
    return (
      <a
        href={exercise.links.self}
        className={classNames.join(' ')}
        ref={ref as React.RefObject<HTMLAnchorElement>}
        {...props}
      >
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} track={track} />
        <GraphicalIcon icon="chevron-right" className="--action-icon" />
      </a>
    )
  } else {
    return (
      <div
        className={`c-exercise-widget --locked --${size}`}
        ref={ref as React.RefObject<HTMLDivElement>}
        {...props}
      >
        <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
        <Info exercise={exercise} solution={solution} track={track} />
        <GraphicalIcon icon="lock" className="--action-icon" />
      </div>
    )
  }
})
