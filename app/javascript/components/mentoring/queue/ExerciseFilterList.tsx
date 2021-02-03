import React, { useCallback } from 'react'
import { GraphicalIcon } from '../../common'

export type Exercise = {
  slug: string
  iconUrl: string
  title: string
  count: number
}

const ExerciseFilter = ({
  title,
  iconUrl,
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
        <img
          role="presentation"
          className="c-icon c-exercise-icon"
          src={iconUrl}
        />
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
      <div className="exercises">
        {exercises.map((exercise) => (
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
