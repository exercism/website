import React, { useRef } from 'react'
import { Concept } from '../types'
import { ConceptTooltip } from '../tooltips/ConceptTooltip'
import { LazyTippy } from '../misc/LazyTippy'
import { followCursor } from 'tippy.js'

export type Props = { concept: Concept }

export const ConceptWidget = ({ concept }: Props): JSX.Element => {
  const conceptRef = useRef(null)

  return (
    <LazyTippy
      content={<ConceptTooltip endpoint={concept.links.tooltip} />}
      animation="shift-away-subtle"
      followCursor="horizontal"
      maxWidth="none"
      plugins={[followCursor]}
    >
      <a
        ref={conceptRef}
        href={concept.links.self}
        className="unlocked-concept"
      >
        <div className="c-concept-icon c--small">
          {concept.name.slice(0, 2)}
        </div>
        <div className="name">{concept.name}</div>
      </a>
    </LazyTippy>
  )
}
