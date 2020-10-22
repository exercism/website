import React, { useEffect, useRef } from 'react'
import { CompleteIcon } from './CompleteIcon'

import { IConcept, ConceptStatus } from './concept-types'

import { emitConceptElement } from './helpers/concept-element-handler'

export const Concept = ({
  slug,
  name,
  web_url,
  handleEnter,
  handleLeave,
  status,
  isInactive,
}: IConcept & {
  status: ConceptStatus
  isInactive: boolean
}) => {
  const conceptRef = useRef(null)

  useEffect(() => {
    const current = conceptRef.current
    emitConceptElement(slug, current)
    return () => {
      emitConceptElement(slug)
    }
  }, [slug, conceptRef])

  // Build the class list
  let classes = ['card']
  classes.push(`card-${status}`)
  if (isInactive) {
    classes.push('card-inactive')
  }

  return (
    <a
      ref={conceptRef}
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
        <CompleteIcon show={ConceptStatus.Completed === status} />
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
