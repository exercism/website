import React, { useState, useEffect } from 'react'
import { Exercise, ExerciseStatus, Track, SolutionForStudent } from '../types'
import { Icon, ExerciseWidget } from '../common'
import { usePanel } from '../../hooks/use-panel'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../FetchingBoundary'

export const ExerciseStatusChart = ({
  exercisesData,
  links,
}: {
  exercisesData: { [slug: string]: [string, string] }
  links: { exercise: string; tooltip: string }
}): JSX.Element => {
  return (
    <div className="exercises">
      {Object.keys(exercisesData).map((key) => {
        const slug = key
        const status = exercisesData[key][0]
        const type = exercisesData[key][1]

        const dotLinks = {
          tooltip: links.tooltip.replace('$SLUG', slug),
          exercise:
            status !== 'locked'
              ? links.exercise.replace('$SLUG', slug)
              : undefined,
        }

        if (
          status !== 'locked' &&
          status !== 'available' &&
          status !== 'started' &&
          status !== 'iterated' &&
          status !== 'completed' &&
          status !== 'published'
        ) {
          throw new Error('Invalid status')
        }

        return (
          <ExerciseStatusDot
            key={slug}
            slug={slug}
            exerciseStatus={status}
            type={type}
            links={dotLinks}
          />
        )
      })}
    </div>
  )
}

const DEFAULT_ERROR = new Error('Unable to load information')

const LoadingComponent = () => {
  const [isShowing, setIsShowing] = useState(false)

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsShowing(true)
    }, 200)

    return () => clearTimeout(timer)
  }, [])

  return isShowing ? (
    <Icon icon="spinner" alt="Loading exercise data" className="--spinner" />
  ) : null
}

const ExerciseStatusDot = ({
  slug,
  exerciseStatus,
  type,
  links,
}: {
  slug: string
  exerciseStatus: ExerciseStatus
  type: string
  links: {
    tooltip: string
    exercise?: string
  }
}) => {
  const {
    open,
    setOpen,
    setButtonElement,
    setPanelElement,
    styles,
    attributes,
  } = usePanel({
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

  const isMountedRef = useIsMounted()
  const { data, error, status } = useRequestQuery<{
    track: Track
    exercise: Exercise
    solution: SolutionForStudent
  }>(
    `exercise-tooltip-${slug}`,
    { endpoint: links.tooltip, options: { enabled: open } },
    isMountedRef
  )

  return (
    <React.Fragment>
      <ReferenceElement
        ref={setButtonElement}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        className={`c-ed --${exerciseStatus} --${type}`}
        link={links.exercise}
      />
      {open ? (
        <div
          className="c-exercise-tooltip"
          ref={setPanelElement}
          style={styles.popper}
          {...attributes.popper}
        >
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
            LoadingComponent={LoadingComponent}
          >
            {data ? (
              <ExerciseWidget
                exercise={data.exercise}
                solution={data.solution}
                track={data.track}
                size="tooltip"
              />
            ) : (
              <span>Unable to load information</span>
            )}
          </FetchingBoundary>
        </div>
      ) : null}
    </React.Fragment>
  )
}

const ReferenceElement = React.forwardRef<
  HTMLElement,
  React.HTMLProps<HTMLDivElement> &
    React.HTMLProps<HTMLAnchorElement> & { link?: string }
>(({ link, ...props }, ref) => {
  return link ? (
    <a href={link} ref={ref as React.RefObject<HTMLAnchorElement>} {...props} />
  ) : (
    <div ref={ref as React.RefObject<HTMLDivElement>} {...props} />
  )
})
