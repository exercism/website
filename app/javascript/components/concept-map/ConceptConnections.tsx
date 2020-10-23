import React from 'react'

import { ConceptConnection } from './concept-map-types'
import { ConnectionPathSVG } from './ConnectionPathSVG'

/**
 * ConceptConnections
 */
export const ConceptConnections = ({
  connections,
  activeConcepts,
}: {
  connections: ConceptConnection[]
  activeConcepts: Set<string>
}) => {
  return (
    <>
      {connections.map((connection, i) => {
        const key = connectionToKey(connection)
        return (
          <ConnectionPathSVG
            key={key}
            activeConcepts={activeConcepts}
            connection={connection}
          />
        )
      })}
    </>
  )
}

function connectionToKey({ from, to }: ConceptConnection): string {
  return `path-${from}-${to}`
}
