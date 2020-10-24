import React, { useState } from 'react'

import { Concept } from './Concept'
import { ConceptConnections } from './ConceptConnections'

import {
  IConceptMap,
  IConcept,
  isIConcept,
  ConceptConnection,
} from './concept-map-types'

type AdjacentIndex = Map<string, Set<string>>
type RelationReducer = (connection: ConceptConnection) => [string, string]

interface IndexAdjacentBySlug {
  (
    connections: ConceptConnection[],
    relationReducer: RelationReducer,
    index?: AdjacentIndex
  ): AdjacentIndex
}

export const ConceptMap = ({
  concepts,
  levels,
  connections,
  status,
}: IConceptMap): JSX.Element => {
  const [activeSlug, setActiveSlug] = useState<string | null>(null)

  const conceptsBySlug = indexConceptsBySlug(concepts)
  const descendantsBySlug = indexDescendantsBySlug(connections)
  const parentsBySlug = indexParentsBySlug(connections)

  const activeSlugs = findAllActiveSlugs(
    parentsBySlug,
    descendantsBySlug,
    activeSlug
  )

  return (
    <figure className="c-concepts-map">
      <div className="track">
        {levels.map((layer, i: number) => (
          <div key={`layer-${i}`} className="layer">
            {layer
              .map((conceptSlug) => conceptsBySlug.get(conceptSlug))
              .filter(isIConcept)
              .map((concept) => {
                const slug = concept.slug
                const isInactive = activeSlug !== null && !activeSlugs.has(slug)

                return (
                  <Concept
                    key={slug}
                    slug={slug}
                    name={concept.name}
                    web_url={concept.web_url}
                    handleEnter={() => setActiveSlug(slug)}
                    handleLeave={() => setActiveSlug(null)}
                    status={status[slug] ?? 'locked'}
                    isInactive={isInactive}
                  />
                )
              })}
          </div>
        ))}
      </div>
      <ConceptConnections
        connections={connections}
        activeConcepts={activeSlugs}
      />
    </figure>
  )
}

function indexConceptsBySlug(concepts: IConcept[]): Map<string, IConcept> {
  return concepts.reduce((memo, concept) => {
    memo.set(concept.slug, concept)
    return memo
  }, new Map<string, IConcept>())
}

const indexAdjacentBySlug: IndexAdjacentBySlug = function (
  connections,
  relationReducer,
  index = new Map()
) {
  const addToIndex = (index: AdjacentIndex, from: string, to: string): void => {
    const adjacent = index.get(from) ?? new Set()
    adjacent.add(to)
    index.set(from, adjacent)
  }

  return connections.reduce((relatives, connection) => {
    const [from, to] = relationReducer(connection)
    addToIndex(relatives, from, to)
    return relatives
  }, index)
}

const indexParentsBySlug = function (
  connections: ConceptConnection[]
): AdjacentIndex {
  const parentReducer: RelationReducer = (connection) => [
    connection.to,
    connection.from,
  ]
  return indexAdjacentBySlug(connections, parentReducer)
}

const indexDescendantsBySlug = function (
  connections: ConceptConnection[]
): AdjacentIndex {
  const descendantReducer: RelationReducer = (connection) => [
    connection.from,
    connection.to,
  ]
  return indexAdjacentBySlug(connections, descendantReducer)
}

const findAllActiveSlugs = function (
  parentsBySlug: AdjacentIndex,
  descendantsBySlug: AdjacentIndex,
  activeSlug: string | null
): Set<string> {
  if (activeSlug === null) {
    return new Set()
  }

  const ancestorSlugs = [activeSlug]
  const processedSlugs = new Set<string>()
  const queue = [activeSlug]

  while (queue.length > 0) {
    const slug = queue.pop()
    const parentSlugs = slug ? Array.from(parentsBySlug.get(slug) ?? []) : []
    const unprocessedParentSlugs = parentSlugs.filter(
      (slug) => !processedSlugs.has(slug)
    )
    unprocessedParentSlugs.forEach((slug) => processedSlugs.add(slug))
    queue.push(...unprocessedParentSlugs)
    ancestorSlugs.push(...unprocessedParentSlugs)
  }

  return new Set([
    ...ancestorSlugs,
    ...Array.from(descendantsBySlug.get(activeSlug) ?? []),
  ])
}
