import React, { useState, useCallback, useMemo, useEffect } from 'react'
import { ExerciseIcon, GraphicalIcon } from '../../common'
import { FetchingBoundary } from '../../FetchingBoundary'
import { MentoredTrackExercise } from '../../types'
import { QueryStatus } from '@tanstack/react-query'

export type Props = {
  exercises: MentoredTrackExercise[] | undefined
  value: MentoredTrackExercise | null
  setValue: (value: MentoredTrackExercise | null) => void
}

const AllExerciseFilter = ({
  count,
  checked,
  onChange,
}: {
  count: number
  checked: boolean
  onChange: (e: React.ChangeEvent) => void
}): JSX.Element => {
  return (
    <label className="c-radio-wrapper">
      <input type="radio" onChange={onChange} checked={checked} />
      <div className="row">
        <div className="c-radio" />
        <GraphicalIcon icon="exercise" category="graphics" />
        <div className="title">All exercises</div>
        <div className="count">{count}</div>
      </div>
    </label>
  )
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
  const classNames = `c-radio-wrapper ${count == 0 ? 'zero' : null}`
  return (
    <label className={classNames}>
      <input type="radio" onChange={onChange} checked={checked} />
      <div className="row">
        <div className="c-radio" />
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
  const [isShowingExercisesToMentor, setIsShowingExercisesToMentor] =
    useState(true)
  const [isShowingExercisesCompleted, setIsShowingExercisesCompleted] =
    useState(false)

  const exercisesToShow = useMemo(() => {
    if (!exercises) {
      return []
    }

    return exercises
      .filter((exercise) => {
        if (exercise.slug === value?.slug) {
          return true
        }

        return isShowingExercisesToMentor ? exercise.count !== 0 : true
      })
      .filter((exercise) => {
        if (exercise.slug === value?.slug) {
          return true
        }

        return isShowingExercisesCompleted ? exercise.completedByMentor : true
      })
      .filter((exercise) =>
        exercise.title.match(new RegExp(`^${searchQuery}`, 'i'))
      )
  }, [
    exercises,
    isShowingExercisesCompleted,
    isShowingExercisesToMentor,
    searchQuery,
    value?.slug,
  ])

  const handleChange = useCallback(
    (e, optionValue) => {
      setSearchQuery('')
      setValue(optionValue)
    },
    [setValue]
  )

  const handleShowCompletedExercises = useCallback(
    (e) => {
      if (!exercises) {
        return
      }

      setIsShowingExercisesCompleted(e.target.checked)
      setValue(null)
    },
    [exercises, setValue]
  )

  const handleSearchBarChange = useCallback((e) => {
    setSearchQuery(e.target.value)
  }, [])

  useEffect(() => {
    setSearchQuery('')
    setIsShowingExercisesToMentor(true)
    setIsShowingExercisesCompleted(false)
  }, [JSON.stringify(exercises)])

  return (
    <>
      <div className="exercise-filter">
        <div className="c-search-bar">
          <input
            value={searchQuery}
            onChange={handleSearchBarChange}
            className="--search"
            placeholder="Search by Exercise name"
          />
        </div>
        <label className="c-checkbox-wrapper filter">
          <input
            type="checkbox"
            checked={isShowingExercisesToMentor}
            onChange={() =>
              setIsShowingExercisesToMentor(!isShowingExercisesToMentor)
            }
          />
          <div className="row">
            <div className="c-checkbox">
              <GraphicalIcon icon="checkmark" />
            </div>
            Only show exercises that need mentoring
          </div>
        </label>
        <label className="c-checkbox-wrapper filter">
          <input
            type="checkbox"
            checked={isShowingExercisesCompleted}
            onChange={handleShowCompletedExercises}
          />
          <div className="row">
            <div className="c-checkbox">
              <GraphicalIcon icon="checkmark" />
            </div>
            Only show exercises I've completed
          </div>
        </label>
      </div>
      <div className="exercises">
        <AllExerciseFilter
          key="all"
          onChange={(e) => handleChange(e, null)}
          checked={value === null}
          count={
            exercises?.reduce((sum, exercise) => sum + exercise.count, 0) || 0
          }
        />
        {exercisesToShow.map((exercise) => (
          <ExerciseFilter
            key={exercise.slug}
            onChange={(e) => handleChange(e, exercise)}
            checked={value?.slug === exercise.slug}
            {...exercise}
          />
        ))}
      </div>
    </>
  )
}
