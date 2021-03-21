import React, { useEffect, useRef, useState, MouseEventHandler } from 'react'
import { ConceptTooltip } from '../tooltips'

import { IConcept, ConceptStatus } from './concept-map-types'

import { emitConceptElement } from './helpers/concept-element-svg-handler'
import {
  addVisibilityListener,
  removeVisibilityListener,
  Visibility,
} from './helpers/concept-visibility-handler'
import { wrapAnimationFrame } from './helpers/animation-helpers'
import { PureExerciseStatusBar } from './ExerciseStatusBar'
import { ConceptIcon } from '../common/ConceptIcon'

type ConceptProps = IConcept & {
  handleEnter: MouseEventHandler
  handleLeave: MouseEventHandler
  status: ConceptStatus
  isActive: boolean
  isActiveHover: boolean
}

export const Concept = ({
  slug,
  name,
  webUrl,
  tooltipUrl,
  handleEnter,
  handleLeave,
  status,
  isActive,
  isActiveHover,
  exercises,
}: ConceptProps): JSX.Element => {
  const isLocked = status === 'locked'
  // sets the initial visibility, to avoid the flash of unstyled content
  const [visibility, setVisibility] = useState<Visibility>('hidden')

  // reference to the concept anchor tag
  const conceptRef = useRef(null)

  // the state of the anchor tag focus (if it is the active element)
  const [hasFocus, setHasFocus] = useState<boolean>(
    document.activeElement === conceptRef.current
  )

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
      <a
        ref={conceptRef}
        href={webUrl}
        id={conceptSlugToId(slug)}
        className={classes.join(' ')}
        data-concept-slug={slug}
        data-concept-status={status}
        onFocus={() => setHasFocus(true)}
        onBlur={() => setHasFocus(false)}
        onMouseEnter={wrapAnimationFrame(handleEnter)}
        onMouseLeave={wrapAnimationFrame(handleLeave)}
      >
        <div className="display">
          <ConceptIcon name={name} size="small" />
          <div className="name">{name}</div>
        </div>
        {!isLocked && <PureExerciseStatusBar {...exercises} />}
      </a>
      <ConceptTooltip
        contentEndpoint={tooltipUrl}
        hoverRequestToShow={isActiveHover}
        focusRequestToShow={hasFocus}
        referenceElement={conceptRef.current}
        referenceConceptSlug={slug}
      />
    </div>
  )
}

export const PureConcept = React.memo(Concept)

export function conceptExerciseSlugToId(slug: string): string {
  return `concept-exercise-${slug}`
}

export function conceptSlugToId(slug: string): string {
  return `concept-${slug}`
}
