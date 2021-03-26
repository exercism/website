import React from 'react'
import { Exercise, ExerciseStatus, Track } from '../types'
import { ExerciseWidget } from '../common'
import { usePanel } from '../../hooks/use-panel'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { FetchingBoundary } from '../FetchingBoundary'

export const ExerciseStatusChart = ({
  exerciseStatuses,
}: {
  exerciseStatuses: ExerciseStatus[]
}): JSX.Element => {
  return (
    <div className="exercises">
      {exerciseStatuses.map((status) => {
        switch (status.status) {
          case 'locked':
            return (
              <LockedExerciseStatus key={status.slug} exerciseStatus={status} />
            )
          case 'available':
            return (
              <a
                key={status.slug}
                href={status.links.exercise}
                className={`c-ed --a`}
              />
            )
          case 'in_progress':
            return (
              <a
                key={status.slug}
                href={status.links.exercise}
                className={`c-ed --ip`}
              />
            )
          case 'completed':
            return (
              <a
                key={status.slug}
                href={status.links.exercise}
                className={`c-ed --c`}
              />
            )
        }
      })}
    </div>
  )
}

const DEFAULT_ERROR = new Error('Unable to load information')

const LockedExerciseStatus = ({
  exerciseStatus,
}: {
  exerciseStatus: ExerciseStatus
}) => {
  if (exerciseStatus.status !== 'locked') {
    throw new Error('Must be a locked exercise')
  }

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
  }>(
    `exercise-tooltip-${exerciseStatus.slug}`,
    { endpoint: exerciseStatus.links.tooltip, options: { enabled: open } },
    isMountedRef
  )

  return (
    <React.Fragment>
      <div
        ref={setButtonElement}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        className="c-ed --l"
      />
      <div ref={setPanelElement} style={styles.popper} {...attributes.popper}>
        {open ? (
          <FetchingBoundary
            status={status}
            error={error}
            defaultError={DEFAULT_ERROR}
          >
            {data ? (
              <ExerciseWidget
                exercise={data.exercise}
                track={data.track}
                size="tooltip"
              />
            ) : (
              <span>Unable to load information</span>
            )}
          </FetchingBoundary>
        ) : null}
      </div>
    </React.Fragment>
  )
}
