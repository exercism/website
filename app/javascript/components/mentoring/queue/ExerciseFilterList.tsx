import React, { useState, useCallback, useMemo } from 'react'
import { ExerciseIcon, GraphicalIcon } from '../../common'

export type Exercise = {
  slug: string
  iconName: string
  title: string
  count: number
  completedByMentor: boolean
}

const ExerciseFilter = ({
  title,
  iconName,
  count,
  checked,
  onChange,
}: Exercise & {
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
        <ExerciseIcon icon={iconName} />
        <div className="title">{title}</div>
        <div className="count">{count}</div>
      </div>
    </label>
  )
}

export const ExerciseFilterList = ({
  exercises,
  value,
  setValue,
}: {
  exercises: Exercise[]
  value: string[]
  setValue: (value: string[]) => void
}): JSX.Element => {
  const [searchQuery, setSearchQuery] = useState('')
  const [isShowingExercisesToMentor, setIsShowingExercisesToMentor] = useState(
    true
  )
  const [
    isShowingExercisesCompleted,
    setIsShowingExercisesCompleted,
  ] = useState(false)

  const exercisesToShow = useMemo(() => {
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
      setIsShowingExercisesCompleted(e.target.checked)

      if (!e.target.checked) {
        setValue([])
      }

      setValue(
        exercises
          .filter((exercise) => exercise.completedByMentor)
          .map((exercise) => exercise.slug)
      )
    },
    [exercises, setValue]
  )

  const handleSelectAll = useCallback(() => {
    setValue(exercisesToShow.map((exercise) => exercise.slug))
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
            onChange={(e) => handleChange(e, exercise.slug)}
            checked={value.includes(exercise.slug)}
            {...exercise}
          />
        ))}
      </div>
    </React.Fragment>
  )
}
