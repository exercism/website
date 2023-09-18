import React, { useCallback, useMemo, useState } from 'react'

import { PureConcept } from './Concept'
import { ConceptConnections } from './ConceptConnections'

import {
  IConceptMap,
  IConcept,
  isIConcept,
  ConceptConnection,
} from './concept-map-types'
import { useFontLoaded } from './hooks/useFontLoaded'
import { camelize } from 'humps'

type AdjacentIndex = Map<string, Set<string>>
type RelationReducer = (connection: ConceptConnection) => [string, string]

interface IndexAdjacentBySlug {
  (
    connections: ConceptConnection[],
    relationReducer: RelationReducer,
    index?: AdjacentIndex
  ): AdjacentIndex
}

export default function ConceptMap({
  concepts,
  levels,
  connections,
  status,
  exercisesData,
}: IConceptMap): JSX.Element {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const fontLoaded = useFontLoaded('Poppins')
  const [activeSlug, setActiveSlug] = useState<string | null>(null)
  const unsetActiveSlug = useCallback(
    () => setActiveSlug(null),
    [setActiveSlug]
  )

  const conceptsBySlug = useMemo(
    () => indexConceptsBySlug(concepts),
    [concepts]
  )
  const descendantsBySlug = useMemo(
    () => indexDescendantsBySlug(connections),
    [connections]
  )
  const parentsBySlug = useMemo(
    () => indexParentsBySlug(connections),
    [connections]
  )
  const activeSlugsBySlug = useMemo(
    () => indexActiveSlugsBySlug(concepts, parentsBySlug, descendantsBySlug),
    [concepts, parentsBySlug, descendantsBySlug]
  )
  const activeSlugs = activeSlug
    ? activeSlugsBySlug.get(activeSlug) ?? new Set<string>()
    : new Set<string>()

  return (
    <>
      <figure className="c-concepts-map">
        <div className="track">
          {levels.map((layer, i: number) => (
            <div key={`layer-${i}`} className="layer">
              {layer
                .map((conceptSlug) => conceptsBySlug.get(camelize(conceptSlug)))
                .filter(isIConcept)
                .map((concept) => {
                  const slug = camelize(concept.slug)
                  const isActive = activeSlug === null || activeSlugs.has(slug)

                  return (
                    <PureConcept
                      key={slug}
                      slug={slug}
                      name={concept.name}
                      webUrl={concept.webUrl}
                      tooltipUrl={concept.tooltipUrl}
                      exercisesData={exercisesData[slug]}
                      handleEnter={() => setActiveSlug(slug)}
                      handleLeave={unsetActiveSlug}
                      status={status[slug] ?? 'unavailable'}
                      isActive={isActive}
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
    </>
  )
}

function indexConceptsBySlug(concepts: IConcept[]): Map<string, IConcept> {
  return concepts.reduce((memo, concept) => {
    memo.set(camelize(concept.slug), concept)
    return memo
  }, new Map<string, IConcept>())
}

const indexAdjacentBySlug: IndexAdjacentBySlug = function (
  connections,
  relationReducer,
  index = new Map()
): AdjacentIndex {
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
    camelize(connection.to),
    camelize(connection.from),
  ]
  return indexAdjacentBySlug(connections, parentReducer)
}

const indexDescendantsBySlug = function (
  connections: ConceptConnection[]
): AdjacentIndex {
  const descendantReducer: RelationReducer = (connection) => [
    camelize(connection.from),
    camelize(connection.to),
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

  const activeSlugs = new Set([activeSlug])
  const processedSlugs = new Set<string>()
  const queue = [activeSlug]

  while (queue.length > 0) {
    const slug = queue.pop() as string
    if (processedSlugs.has(slug)) {
      continue
    }
    activeSlugs.add(slug)
    const parentSlugs = slug ? Array.from(parentsBySlug.get(slug) ?? []) : []
    queue.push(...parentSlugs)
  }

  const descendantSlugs = descendantsBySlug.get(activeSlug) ?? new Set<string>()
  descendantSlugs.forEach((descendantSlug) => activeSlugs.add(descendantSlug))

  return activeSlugs
}

const indexActiveSlugsBySlug = function (
  concepts: IConcept[],
  parentsBySlug: AdjacentIndex,
  descendantsBySlug: AdjacentIndex
): Map<string, Set<string>> {
  const index = new Map<string, Set<string>>()

  concepts.forEach((concept) => {
    const slug = camelize(concept.slug)
    const activeSlugsWhenConceptActive = findAllActiveSlugs(
      parentsBySlug,
      descendantsBySlug,
      slug
    )
    index.set(slug, activeSlugsWhenConceptActive)
  })

  return index
}
