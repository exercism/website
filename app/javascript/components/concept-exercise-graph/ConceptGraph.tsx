import React, { useState } from 'react'

import { Concept } from './Concept'
import { ConceptConnections } from './ConceptConnections'

import { IConcept, IConceptGraph, ConceptLayer } from './concept-types'

export const ConceptGraph = ({
  concepts,
  layout,
  connections,
}: IConceptGraph) => {
  console.log({ concepts, layout, connections })

  const [active, setActive] = useState<string | null>(null)

  const conceptsBySlug = concepts.reduce((memo, concept) => {
    memo.set(concept.slug, concept)
    return memo
  }, new Map<string, IConcept>())

  return (
    <figure className="c-concept-graph">
      <ConceptConnections connections={connections} activeConcept={active} />
      <div className="track">
        {layout.map((layer: ConceptLayer, i: number) => (
          <div key={`layer-${i}`} className="layer">
            {layer.map((conceptSlug) => {
              const concept = conceptsBySlug.get(conceptSlug)

              // TODO: fix this error typescript error since it _may_ return undefined
              if (!concept) return 'no concept'

              return (
                <Concept
                  uuid={concept.uuid}
                  index={concept.index}
                  slug={concept.slug}
                  conceptExercise={concept.conceptExercise}
                  prerequisites={concept.prerequisites}
                  status={concept.status}
                  isActive={active === concept.slug}
                  handleEnter={() => setActive(concept.slug)}
                  handleLeave={() => setActive(null)}
                />
              )
            })}
          </div>
        ))}
      </div>
    </figure>
  )
}
