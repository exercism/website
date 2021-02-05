import React, { useState, useCallback, useMemo } from 'react'
import { GraphicalIcon } from '../../common'

export type Exercise = {
  slug: string
  iconName: string
  title: string
  count: number
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
      <div className="c-checkbox">
        <GraphicalIcon icon="checkmark" />
      </div>
      {/* TODO: Convert to ExerciseIcon */}
      <GraphicalIcon icon={iconName} className="c-exercise-icon" />
      <div className="title">{title}</div>
      <div className="count">{count}</div>
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
  const [isShowingExercisesToMentor, setIsShowingExercisesToMentor] = useState(
    true
  )

  const exercisesToShow = useMemo(
    () =>
      exercises.filter((exercise) =>
        isShowingExercisesToMentor ? exercise.count !== 0 : true
      ),
    [exercises, isShowingExercisesToMentor]
  )

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
  return (
    <div className="exercise-filter">
      <h3>Filter by exercise</h3>
      {/* TODO: Exercise searching */}
      <div className="c-search-bar">
        <input className="--search" placeholder="Search by Exercise name" />
      </div>
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
        <input type="checkbox" />
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
    </div>
  )
}
