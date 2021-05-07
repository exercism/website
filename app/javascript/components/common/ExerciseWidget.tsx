import React, { forwardRef } from 'react'
import { Track, Exercise, SolutionForStudent } from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Info } from './exercise-widget/Info'
import { usePanel } from '../../hooks/use-panel'
import { ExerciseTooltip } from '../tooltips/ExerciseTooltip'

type Links = {
  tooltip: string
}

type Props = {
  exercise: Exercise
  track?: Track
  solution?: SolutionForStudent
  links?: Links
  renderAsLink: boolean
  renderBlurb: boolean
  isSkinny: boolean
}

export const ExerciseWidget = ({
  exercise,
  track,
  solution,
  links,
  renderAsLink,
  renderBlurb,
  isSkinny,
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
        renderAsLink={renderAsLink}
        renderBlurb={renderBlurb}
        isSkinny={isSkinny}
        {...buttonAttributes}
        {...mouseEvents}
      />
      {open && links && links.tooltip ? (
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
>(
  (
    {
      exercise,
      track,
      solution,
      renderAsLink,
      renderBlurb,
      isSkinny,
      ...props
    },
    ref
  ) => {
    const info = (
      <Info
        exercise={exercise}
        solution={solution}
        track={track}
        renderBlurb={renderBlurb}
        isSkinny={isSkinny}
      />
    )
    if (solution || exercise.isUnlocked) {
      const classNames = [
        'c-exercise-widget',
        `--${solution ? solution.status : 'available'}`,
        exercise.isRecommended ? '--recommended' : '',
        `--${renderAsLink ? 'interactive' : 'static'}`,
        isSkinny ? '--skinny' : '',
      ]
        .filter((name) => name.length > 0)
        .join(' ')

      const url = solution
        ? solution.url
        : exercise.isUnlocked
        ? exercise.links.self
        : '#'
      return renderAsLink ? (
        <a
          ref={ref as React.RefObject<HTMLAnchorElement>}
          href={url}
          className={classNames}
          {...props}
        >
          <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
          {info}
          <GraphicalIcon icon="chevron-right" className="--action-icon" />
        </a>
      ) : (
        <div
          ref={ref as React.RefObject<HTMLDivElement>}
          className={classNames}
          {...props}
        >
          <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
          {info}
        </div>
      )
    } else {
      const classNames = [
        'c-exercise-widget',
        '--locked',
        `--${renderAsLink ? 'interactive' : 'static'}`,
        isSkinny ? '--skinny' : '',
      ]
        .filter((name) => name.length > 0)
        .join(' ')

      return (
        <div
          className={classNames}
          ref={ref as React.RefObject<HTMLDivElement>}
          {...props}
        >
          <ExerciseIcon iconUrl={exercise.iconUrl} title={exercise.title} />
          {info}
          <GraphicalIcon icon="lock" className="--action-icon" />
        </div>
      )
    }
  }
)

ExerciseWidget.defaultProps = {
  renderAsLink: true,
  renderBlurb: true,
  isSkinny: false,
}
