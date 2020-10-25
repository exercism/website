import React, { useEffect, useReducer } from 'react'
import { useWebpageSize } from './hooks/useWebpageSize'

import { PurePathLineSVG } from './PathLineSVG'
import { PurePathLineEndSVG } from './PathLineEndSVG'

import { ConceptConnection, ConceptPath } from './concept-map-types'

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

  const path: ConceptPath | null =
    startElementRef !== null && endElementRef !== null
      ? determinePath(startElementRef, endElementRef)
      : null

  if (path === null) return null

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
  const isActive =
    !existsActivePaths ||
    (activeConcepts.has(connection.from) && activeConcepts.has(connection.to))

  const classNames = ['canvas', normalizedPath.status]
  if (isActive) {
    classNames.push('active')
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
        <PurePathLineSVG path={normalizedPath} />
        <PurePathLineEndSVG
          cx={normalizedPath.start.x}
          cy={normalizedPath.start.y}
          radius={radius}
          status={normalizedPath.status}
        />
        <PurePathLineEndSVG
          cx={normalizedPath.end.x}
          cy={normalizedPath.end.y}
          radius={radius}
          status={normalizedPath.status}
        />
      </g>
    </svg>
  )
}
