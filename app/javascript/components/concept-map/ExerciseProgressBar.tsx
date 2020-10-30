import * as React from 'react'

export const ExerciseProgressBar = ({
  completed,
  exercises,
  hidden = false,
}: {
  completed: number
  exercises: number
  hidden?: boolean
}): JSX.Element => {
  const percent = exercises > 0 ? (completed / exercises) * 100 : 0
  const classNames = []
  if (hidden) {
    classNames.push('hidden')
  }

  if (exercises === 0) {
    classNames.push('no-exercises')
  } else if (completed === exercises) {
    classNames.push('complete')
  }

  return (
    <progress
      className={classNames.join(' ')}
      value={completed}
      max={exercises}
      aria-label={`${completed} of ${exercises} exercises complete`}
    >{`${percent}%`}</progress>
  )
}

export const PureExerciseProgressBar = React.memo(ExerciseProgressBar)
