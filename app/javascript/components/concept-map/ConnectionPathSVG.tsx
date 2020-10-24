import React, { useEffect, useReducer } from 'react'
import { useWebpageSize } from './hooks/useWebpageSize'

import { PathLineSVG } from './PathLineSVG'
import { PathLineEndSVG } from './PathLineEndSVG'

import { ConceptConnection } from './concept-map-types'

import {
  addElementDispatcher,
  removeElementDispatcher,
  ElementReducer,
} from './helpers/concept-element-svg-handler'

import {
  determinePath,
  normalizePathToCanvasSize,
} from './helpers/path-helpers'
import { getCircleRadius, getLineWidth } from './helpers/style-helpers'

const elementReducer: ElementReducer = (_, nextElements) => nextElements

export const ConnectionPathSVG = ({
  activeConcepts,
  connection,
}: {
  activeConcepts: Set<string>
  connection: ConceptConnection
}): JSX.Element | null => {
  const webpageSize = useWebpageSize()
  const [{ startElementRef, endElementRef }, dispatchRef] = useReducer(
    elementReducer,
    {
      startElementRef: null,
      endElementRef: null,
    }
  )

  useEffect(() => {
    addElementDispatcher(dispatchRef, connection.from, connection.to)
    return () => {
      removeElementDispatcher(dispatchRef, connection.from, connection.to)
    }
  }, [connection, dispatchRef, webpageSize])

  if (startElementRef === null || endElementRef === null) return null

  const path = determinePath(startElementRef, endElementRef)
  const radius = getCircleRadius()
  const lineWidth = getLineWidth()

  // calculate minimum dimensions for view-box
  const width = Math.abs(path.end.x - path.start.x) + 2 * radius + 2 * lineWidth
  const height =
    Math.abs(path.end.y - path.start.y) + 2 * radius + 2 * lineWidth

  // calculate amount to translate svg element to be in position
  const leftToRight = path.start.x <= path.end.x
  const translateX =
    (leftToRight ? path.start.x : path.end.x) - radius - lineWidth
  const translateY = path.start.y - radius - lineWidth

  const normalizedPath = normalizePathToCanvasSize(path, width, height)

  // Compute ClassNames
  const existsActivePaths = activeConcepts.size > 0
  const isInactive =
    existsActivePaths &&
    !(activeConcepts.has(connection.from) && activeConcepts.has(connection.to))

  const classNames = ['canvas', normalizedPath.status]
  if (isInactive) {
    classNames.push('inactive')
  }

  return (
    <svg
      viewBox={`0 0 ${width} ${height}`}
      style={{
        width: `${width}px`,
        height: `${height}px`,
        transform: `translate(${translateX}px, ${translateY}px)`,
      }}
      className={classNames.join(' ')}
      data-from={connection.from}
      data-to={connection.to}
    >
      <g>
        <PathLineSVG path={normalizedPath} />
        <PathLineEndSVG
          coordinate={normalizedPath.start}
          radius={radius}
          status={normalizedPath.status}
        />
        <PathLineEndSVG
          coordinate={normalizedPath.end}
          radius={radius}
          status={normalizedPath.status}
        />
      </g>
    </svg>
  )
}
