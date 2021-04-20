import React, { useEffect, useReducer } from 'react'
import { useWebpageSize } from './hooks/useWebpageSize'

import { PurePathLineSVG } from './PathLineSVG'
import { PurePathLineEndSVG } from './PathLineEndSVG'

import { ConceptConnection, ConceptPathProperties } from './concept-map-types'

import {
  addElementDispatcher,
  removeElementDispatcher,
  ElementReducer,
} from './helpers/concept-element-svg-handler'

import { computePathProperties } from './helpers/path-helpers'

import { camelize } from 'humps'

const elementReducer: ElementReducer = (_, nextElements) => nextElements

export const ConnectionPathSVG = ({
  activeConcepts,
  connection,
}: {
  activeConcepts: Set<string>
  connection: ConceptConnection
}): JSX.Element | null => {
  const from = camelize(connection.from)
  const to = camelize(connection.to)
  const webpageSize = useWebpageSize()
  const [{ startElementRef, endElementRef }, dispatchRef] = useReducer(
    elementReducer,
    {
      startElementRef: null,
      endElementRef: null,
    }
  )

  useEffect(() => {
    addElementDispatcher(dispatchRef, from, to)
    return () => {
      removeElementDispatcher(dispatchRef, from, to)
    }
  }, [from, to, dispatchRef, webpageSize])

  const pathProperties: ConceptPathProperties | null =
    startElementRef !== null && endElementRef !== null
      ? computePathProperties(startElementRef, endElementRef)
      : null

  if (pathProperties === null) return null

  const {
    status,
    height,
    width,
    radius,
    pathStart,
    pathEnd,
    translateX,
    translateY,
    pathCourse,
  } = pathProperties

  // Compute ClassNames
  const existsActivePaths = activeConcepts.size > 0
  const isActive =
    !existsActivePaths || (activeConcepts.has(from) && activeConcepts.has(to))

  const classNames = ['connection', status]
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
      data-from={from}
      data-to={to}
      data-testid={`path-${connection.from}-${connection.to}`}
    >
      <g>
        <PurePathLineSVG
          pathStart={pathStart}
          pathEnd={pathEnd}
          course={pathCourse}
        />
        <PurePathLineEndSVG cx={pathStart.x} cy={pathStart.y} radius={radius} />
        <PurePathLineEndSVG cx={pathEnd.x} cy={pathEnd.y} radius={radius} />
      </g>
    </svg>
  )
}
