import React, { forwardRef } from 'react'
import { Track, Exercise, SolutionForStudent } from '../types'
import { ExerciseIcon } from './ExerciseIcon'
import { GraphicalIcon } from './GraphicalIcon'
import { Info } from './exercise-widget/Info'
import { ExerciseTooltip } from '../tooltips'
import { ExercismTippy } from '../misc/ExercismTippy'
import { assembleClassNames } from '@/utils/assemble-classnames'

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
  isStatic?: boolean
}

export function ExerciseWidget({
  exercise,
  track,
  solution,
  links = {},
  renderBlurb,
  isSkinny,
  isStatic,
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
        isStatic={isStatic}
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
    { exercise, track, solution, renderBlurb, isSkinny, isStatic, ...props },
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

    const classNames = assembleClassNames(
      'c-exercise-widget',
      `--${
        solution
          ? solution.status
          : exercise.isUnlocked
          ? 'available'
          : 'locked'
      }`,
      exercise.isRecommended ? '--recommended' : '',
      isStatic ? '--static' : '--interactive',
      isSkinny ? '--skinny' : ''
    )

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
        {!exercise.isUnlocked && (
          <GraphicalIcon
            icon="lock"
            className="--action-icon sm:block hidden"
          />
        )}
        {solution &&
          isSkinny &&
          (solution.status === 'completed' ||
            solution.status === 'published') && (
            <GraphicalIcon
              icon="green-check"
              className="h-[20px] w-[20px] ml-8 sm:block hidden"
            />
          )}
      </a>
    )
  }
)

ExerciseWidget.defaultProps = {
  renderBlurb: true,
  isSkinny: false,
  isStatic: false,
}
export default ExerciseWidget
