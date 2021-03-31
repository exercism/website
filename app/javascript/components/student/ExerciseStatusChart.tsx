import React, { useState } from 'react'
import { Exercise, ExerciseStatus, Track, SolutionForStudent } from '../types'
import { Icon, ExerciseWidget } from '../common'
import { usePanel } from '../../hooks/use-panel'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../FetchingBoundary'

export const ExerciseStatusChart = ({
  exerciseStatuses,
  links,
}: {
  exerciseStatuses: { [slug: string]: string }
  links: { exercise: string; tooltip: string }
}): JSX.Element => {
  return (
    <div className="exercises">
      {Object.keys(exerciseStatuses).map((key) => {
        const slug = key
        const status = exerciseStatuses[key]

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
            exerciseStatus={{ slug: slug, status: status }}
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

  setTimeout(() => {
    setIsShowing(true)
  }, 200)

  return isShowing ? (
    <Icon icon="spinner" alt="Loading exercise data" className="--spinner" />
  ) : null
}

const ExerciseStatusDot = ({
  exerciseStatus,
  links,
}: {
  exerciseStatus: ExerciseStatus
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
  } = usePanel({ placement: 'right' })

  const isMountedRef = useIsMounted()
  const { data, error, status } = useRequestQuery<{
    track: Track
    exercise: Exercise
    solution: SolutionForStudent
  }>(
    `exercise-tooltip-${exerciseStatus.slug}`,
    { endpoint: links.tooltip, options: { enabled: open } },
    isMountedRef
  )

  const classNames = [
    'c-ed',
    exerciseStatus.status === 'available' ? '--a' : '',
    exerciseStatus.status === 'started' ? '--ip' : '',
    exerciseStatus.status === 'iterated' ? '--ip' : '',
    exerciseStatus.status === 'completed' ? '--c' : '',
    exerciseStatus.status === 'published' ? '--p' : '',
    exerciseStatus.status === 'locked' ? '--l' : '',
  ].filter((name) => name.length > 0)

  return (
    <React.Fragment>
      <ReferenceElement
        ref={setButtonElement}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        className={classNames.join(' ')}
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
