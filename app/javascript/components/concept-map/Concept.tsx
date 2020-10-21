import React from 'react'
import { CompleteIcon } from './CompleteIcon'

import { IConcept, ConceptState } from './concept-types'

export const Concept = ({
  slug,
  name,
  web_url,
  handleEnter,
  handleLeave,
  status,
  isActive,
  isDimmed,
}: IConcept & {
  status: ConceptState
  isActive: boolean
  isDimmed: boolean
}) => {
  // Build the class list
  let classes = ['card']
  classes.push(`card-${status}`)
  if (isActive) {
    classes.push('card-active')
  }
  if (isDimmed) {
    classes.push('dim')
  }

  return (
    <a
      href={web_url}
      id={conceptSlugToId(slug)}
      className={classes.join(' ')}
      data-concept-slug={slug}
      data-concept-status={status}
      onMouseEnter={handleEnter}
      onMouseLeave={handleLeave}
    >
      <div className="display">
        <div className="name">{name}</div>
        <CompleteIcon show={ConceptState.Completed === status} />
      </div>
    </a>
  )
}

export function conceptExerciseSlugToId(slug: string): string {
  return `concept-exercise-${slug}`
}

export function conceptSlugToId(slug: string): string {
  return `concept-${slug}`
}
