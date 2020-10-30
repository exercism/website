import React, { useEffect, useRef, useState, MouseEventHandler } from 'react'
import { CompleteIcon } from './CompleteIcon'

import { IConcept, ConceptStatus } from './concept-map-types'

import { emitConceptElement } from './helpers/concept-element-svg-handler'
import {
  addVisibilityListener,
  removeVisibilityListener,
  Visibility,
} from './helpers/concept-visibility-handler'
import { wrapAnimationFrame } from './helpers/animation-helpers'
import { PureExerciseProgressBar } from './ExerciseProgressBar'

export const Concept = ({
  slug,
  name,
  web_url,
  handleEnter,
  handleLeave,
  status,
  isActive,
  exercises = 0,
  completedExercises = 0,
}: IConcept & {
  handleEnter: MouseEventHandler
  handleLeave: MouseEventHandler
  status: ConceptStatus
  isActive: boolean
}): JSX.Element => {
  const [visibility, setVisibility] = useState<Visibility>('hidden')
  const conceptRef = useRef(null)

  useEffect(() => {
    const current = conceptRef.current
    emitConceptElement(slug, current)
    addVisibilityListener(setVisibility)
    return () => {
      emitConceptElement(slug)
      removeVisibilityListener(setVisibility)
    }
  }, [slug, conceptRef])

  const hasExercises = exercises > 0
  const isStarted = completedExercises > 0

  // Build the class list
  const classes = ['card']
  classes.push(`${status}`)
  if (isActive) {
    classes.push('active')
  }
  if (visibility === 'hidden') {
    classes.push('hidden')
  }

  if (!hasExercises) {
    classes.push('no-exercises')
  } else if (!isStarted) {
    classes.push('not-started')
  }

  return (
    <a
      ref={conceptRef}
      href={web_url}
      id={conceptSlugToId(slug)}
      className={classes.join(' ')}
      data-concept-slug={slug}
      data-concept-status={status}
      onMouseEnter={wrapAnimationFrame(handleEnter)}
      onMouseLeave={wrapAnimationFrame(handleLeave)}
    >
      <div className="display">
        <div className="name">{name}</div>
        <CompleteIcon show={hasExercises && exercises === completedExercises} />
      </div>
      <PureExerciseProgressBar
        completed={completedExercises}
        exercises={exercises}
        hidden={!hasExercises || !isStarted}
      />
    </a>
  )
}

export const PureConcept = React.memo(Concept)

export function conceptExerciseSlugToId(slug: string): string {
  return `concept-exercise-${slug}`
}

export function conceptSlugToId(slug: string): string {
  return `concept-${slug}`
}
