import React, { useState, useEffect, forwardRef } from 'react'
import { Exercise, ExerciseStatus, Track, SolutionForStudent } from '../types'
import { Icon, ExerciseWidget } from '../common'
import { usePanel } from '../../hooks/use-panel'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../FetchingBoundary'

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

export const ExerciseStatusDot = ({
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
}): JSX.Element => {
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
        {...buttonAttributes}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        className={`c-ed --${exerciseStatus} --${type}`}
        link={links.exercise}
      />
      {open ? (
        <div className="c-exercise-tooltip" {...panelAttributes}>
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

const ReferenceElement = forwardRef<
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
