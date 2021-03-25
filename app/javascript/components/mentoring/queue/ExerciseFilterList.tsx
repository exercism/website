import React, { useState, useCallback, useMemo } from 'react'
import { ExerciseIcon, GraphicalIcon } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'
import { MentoredTrackExercise } from '../../types'
import { QueryStatus } from 'react-query'

export type Props = {
  exercises: MentoredTrackExercise[] | undefined
  value: MentoredTrackExercise[]
  setValue: (value: MentoredTrackExercise[]) => void
}

const ExerciseFilter = ({
  title,
  iconUrl,
  count,
  checked,
  onChange,
}: MentoredTrackExercise & {
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
}): JSX.Element => {
  return (
    <label className="c-checkbox-wrapper">
      <input type="checkbox" onChange={onChange} checked={checked} />
      <div className="row">
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        <ExerciseIcon iconUrl={iconUrl} />
        <div className="title">{title}</div>
        <div className="count">{count}</div>
      </div>
    </label>
  )
}

const DEFAULT_ERROR = new Error('Unable to fetch exercises')

export const ExerciseFilterList = ({
  status,
  error,
  ...props
}: Props & { status: QueryStatus; error: unknown }): JSX.Element => {
  return (
    <FetchingBoundary
      error={error}
      status={status}
      defaultError={DEFAULT_ERROR}
    >
      <Component {...props} />
    </FetchingBoundary>
  )
}

const Component = ({ exercises, value, setValue }: Props): JSX.Element => {
  const [searchQuery, setSearchQuery] = useState('')
  const [isShowingExercisesToMentor, setIsShowingExercisesToMentor] = useState(
    true
  )
  const [
    isShowingExercisesCompleted,
    setIsShowingExercisesCompleted,
  ] = useState(false)

  const exercisesToShow = useMemo(() => {
    if (!exercises) {
      return []
    }

    return exercises
      .filter((exercise) =>
        isShowingExercisesToMentor ? exercise.count !== 0 : true
      )
      .filter((exercise) =>
        isShowingExercisesCompleted ? exercise.completedByMentor : true
      )
      .filter((exercise) =>
        exercise.title.match(new RegExp(`^${searchQuery}`, 'i'))
      )
  }, [
    exercises,
    isShowingExercisesCompleted,
    isShowingExercisesToMentor,
    searchQuery,
  ])

  const handleChange = useCallback(
    (e, optionValue) => {
      if (e.target.checked) {
        setValue([...value, optionValue])
      } else {
        setValue(value.filter((v) => v !== optionValue))
      }
    },
    [setValue, value]
  )

  const handleShowCompletedExercises = useCallback(
    (e) => {
      if (!exercises) {
        return
      }

      setIsShowingExercisesCompleted(e.target.checked)

      if (!e.target.checked) {
        setValue([])
      }

      setValue(exercises.filter((exercise) => exercise.completedByMentor))
    },
    [exercises, setValue]
  )

  const handleSelectAll = useCallback(() => {
    setValue(exercisesToShow)
  }, [exercisesToShow, setValue])

  const handleSelectNone = useCallback(() => {
    setValue([])
  }, [setValue])

  const handleSearchBarChange = useCallback((e) => {
    setSearchQuery(e.target.value)
  }, [])

  return (
    <React.Fragment>
      <div className="c-search-bar">
        <input
          value={searchQuery}
          onChange={handleSearchBarChange}
          className="--search"
          placeholder="Search by Exercise name"
        />
      </div>
      <button type="button" onClick={handleSelectAll}>
        Select all
      </button>
      <button type="button" onClick={handleSelectNone}>
        Select none
      </button>
      <label className="c-checkbox-wrapper">
        <input
          type="checkbox"
          checked={isShowingExercisesToMentor}
          onChange={() =>
            setIsShowingExercisesToMentor(!isShowingExercisesToMentor)
          }
        />
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        Only show exercises that need mentoring
      </label>
      <label className="c-checkbox-wrapper">
        <input
          type="checkbox"
          checked={isShowingExercisesCompleted}
          onChange={handleShowCompletedExercises}
        />
        <div className="c-checkbox">
          <GraphicalIcon icon="checkmark" />
        </div>
        Only show exercises I've completed
      </label>
      <div className="exercises">
        {exercisesToShow.map((exercise) => (
          <ExerciseFilter
            key={exercise.slug}
            onChange={(e) => handleChange(e, exercise)}
            checked={value.includes(exercise)}
            {...exercise}
          />
        ))}
      </div>
    </React.Fragment>
  )
}
