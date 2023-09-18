import React, { useEffect, useRef, useState, MouseEventHandler } from 'react'
import { ConceptTooltip } from '../tooltips'

import { IConcept, ConceptStatus, ExerciseData } from './concept-map-types'

import { emitConceptElement } from './helpers/concept-element-svg-handler'
import {
  addVisibilityListener,
  removeVisibilityListener,
  Visibility,
} from './helpers/concept-visibility-handler'
import { wrapAnimationFrame } from './helpers/animation-helpers'
import { PureExerciseStatusBar } from './ExerciseStatusBar'
import { ConceptIcon } from '../common/ConceptIcon'
import { ExercismTippy } from '../misc/ExercismTippy'

type ConceptProps = IConcept & {
  handleEnter: MouseEventHandler
  handleLeave: MouseEventHandler
  status: ConceptStatus
  exercisesData: ExerciseData[]
  isActive: boolean
}

export const Concept = ({
  slug,
  name,
  webUrl,
  tooltipUrl,
  handleEnter,
  handleLeave,
  status,
  exercisesData,
  isActive,
}: ConceptProps): JSX.Element => {
  const isLocked = status === 'locked'
  // sets the initial visibility, to avoid the flash of unstyled content
  const [visibility, setVisibility] = useState<Visibility>('hidden')

  // reference to the concept anchor tag
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

  // Build the class list
  const classes: string[] = ['card']
  classes.push(status)
  if (isActive) {
    classes.push('active')
  }
  if (visibility === 'hidden') {
    classes.push('hidden')
  }

  return (
    <div role="presentation">
      <div
        ref={conceptRef}
        id={conceptSlugToId(slug)}
        className={classes.join(' ')}
        data-concept-slug={slug}
        data-concept-status={status}
      >
        <ExercismTippy
          content={<ConceptTooltip endpoint={tooltipUrl} />}
          duration={[null, 0]}
          interactive
        >
          <a
            className="display"
            href={webUrl}
            onMouseEnter={wrapAnimationFrame(handleEnter)}
            onMouseLeave={wrapAnimationFrame(handleLeave)}
          >
            <ConceptIcon name={name} size="medium" />
            <span className="name" aria-label={getAriaLabel(status)}>
              {name}
            </span>
          </a>
        </ExercismTippy>
        {!isLocked && <PureExerciseStatusBar exercisesData={exercisesData} />}
      </div>
    </div>
  )
}

export const PureConcept = React.memo(Concept)

export function conceptSlugToId(slug: string): string {
  return `concept-${slug}`
}

const getAriaLabel = (status: ConceptStatus): string => {
  switch (status) {
    case 'available':
      return 'Available Concept:'
    case 'learned':
      return 'Learned Concept:'
    case 'mastered':
      return 'Mastered Concept:'
    case 'locked':
      return 'Locked Concept:'
    default:
      return 'Concept:'
  }
}
