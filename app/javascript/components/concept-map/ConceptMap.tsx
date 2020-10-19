import React, { useState } from 'react'

import { Concept } from './Concept'
import { ConceptConnections } from './ConceptConnections'

import { IConceptMap, ConceptLayer } from './concept-map-types'
import { ConceptConnection } from './concept-connection-types'
import { IConcept, isIConcept } from './concept-types'

export const ConceptMap = ({ concepts, levels, connections }: IConceptMap) => {
  const [active, setActive] = useState<string | null>(null)

  const conceptsBySlug = indexConceptsBySlug(concepts)
  const adjacentBySlug = indexAdjacentBySlug(connections)

  const adjacentConceptsToActive = new Set(
    Array.from(
      document.querySelectorAll<HTMLElement>(`.adjacent-to-${active}`)
    ).map((element) => element.dataset.conceptSlug)
  )
  return (
    <figure className="c-concepts-map">
      <ConceptConnections connections={connections} activeConcept={active} />
      <div className="track">
        {levels.map((layer: ConceptLayer, i: number) => (
          <div key={`layer-${i}`} className="layer">
            {layer
              .map((conceptSlug) => conceptsBySlug.get(conceptSlug))
              .filter(isIConcept)
              .map((concept) => {
                const isDimmed =
                  active !== null &&
                  active !== concept.slug &&
                  !adjacentConceptsToActive.has(concept.slug)

                const slug = concept.slug
                return (
                  <Concept
                    key={concept.slug}
                    slug={slug}
                    name={concept.name}
                    web_url={concept.web_url}
                    status={concept.status}
                    handleEnter={() => setActive(slug)}
                    handleLeave={() => setActive(null)}
                    isActive={active === concept.slug}
                    isDimmed={isDimmed}
                    adjacentConcepts={adjacentBySlug.get(concept.slug) ?? []}
                  />
                )
              })}
          </div>
        ))}
      </div>
    </figure>
  )
}

function indexConceptsBySlug(concepts: IConcept[]): Map<string, IConcept> {
  return concepts.reduce((memo, concept) => {
    memo.set(concept.slug, concept)
    return memo
  }, new Map<string, IConcept>())
}

type AdjacentIndex = Map<string, string[]>

function indexAdjacentBySlug(connections: ConceptConnection[]): AdjacentIndex {
  const addToIndex = (index: AdjacentIndex, from: string, to: string): void => {
    const list = index.get(from) ?? []
    list.push(to)
    index.set(from, list)
  }

  return connections.reduce((relatives, connection) => {
    addToIndex(relatives, connection.from, connection.to)
    addToIndex(relatives, connection.to, connection.from)
    return relatives
  }, new Map<string, string[]>())
}
