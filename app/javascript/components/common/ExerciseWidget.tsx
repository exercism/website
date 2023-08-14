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
  renderAsLink: boolean
  renderBlurb: boolean
  isSkinny: boolean
}

export const ExerciseWidget = ({
  exercise,
  track,
  solution,
  links = {},
  renderAsLink,
  renderBlurb,
  isSkinny,
}: Props): JSX.Element => {
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
        renderAsLink={renderAsLink}
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
        ? solution.privateUrl
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
          <GraphicalIcon
            icon="chevron-right"
            className="--action-icon sm:block hidden"
          />
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
