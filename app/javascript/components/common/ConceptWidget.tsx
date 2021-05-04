import React, { useState, useRef } from 'react'
import { Concept } from '../types'
import { ConceptTooltip } from '../tooltips/ConceptTooltip'

export const ConceptWidget = ({
  concept,
}: {
  concept: Concept
}): JSX.Element => {
  const conceptRef = useRef(null)
  const [isHovering, setIsHovering] = useState(false)
  const [isFocused, setIsFocused] = useState(false)

  return (
    <React.Fragment>
      <a
        ref={conceptRef}
        href={concept.links.self}
        className="unlocked-concept"
        onMouseEnter={() => setIsHovering(true)}
        onMouseLeave={() => setIsHovering(false)}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
      >
        <div className="c-concept-icon c--small">
          {concept.name.slice(0, 2)}
        </div>
        <div className="name">{concept.name}</div>
      </a>
      <ConceptTooltip
        contentEndpoint={concept.links.tooltip}
        hoverRequestToShow={isHovering}
        focusRequestToShow={isFocused}
        referenceElement={conceptRef.current}
        referenceConceptSlug={concept.slug}
      />
    </React.Fragment>
  )
}
