import React, { useEffect, useRef } from 'react'

import { ConceptConnection } from './concept-connection-types'

import { defaultDrawPathOptions, drawPath } from './helpers/draw-helpers'
import {
  determinePath,
  normalizePathToCanvasSize,
} from './helpers/path-helpers'
import {
  IDrawHandler,
  addDrawHandler,
  removeDrawHandler,
} from './helpers/concept-element-handler'
import { useWebpageSize } from './hooks/useWebpageSize'

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
          <ConnectionPathCanvas
            key={key}
            activeConcepts={activeConcepts}
            connection={connection}
          />
        )
      })}
    </>
  )
}

const ConnectionPathCanvas = ({
  activeConcepts,
  connection,
}: {
  activeConcepts: Set<string>
  connection: ConceptConnection
}) => {
  const webpageSize = useWebpageSize()
  const canvasRef = useRef(null)

  useEffect(() => {
    const drawSelf: IDrawHandler = (pathStartElement, pathEndElement) => {
      const canvas = canvasRef.current as HTMLCanvasElement | null
      if (!canvas) {
        return
      }

      const ctx = canvas.getContext('2d')
      if (!ctx) {
        return
      }

      if (pathStartElement === null || pathEndElement === null) {
        return
      }

      const path = determinePath(pathStartElement, pathEndElement)

      // Use :root defined CSS variable values to style the path
      const rootStyle = getComputedStyle(document.documentElement)
      const radius = Number(
        rootStyle.getPropertyValue('--c-concept-map-circle-radius')
      )
      const lineWidth = Number(
        rootStyle.getPropertyValue('--c-concept-map-line-width')
      )

      // calculate minimum dimensions for canvas
      const width =
        Math.abs(path.end.x - path.start.x) + 2 * radius + 2 * lineWidth
      const height =
        Math.abs(path.end.y - path.start.y) + 2 * radius + 2 * lineWidth

      // set dimensions
      canvas.width = width * devicePixelRatio
      canvas.height = height * devicePixelRatio

      canvas.style.width = `${width}px`
      canvas.style.height = `${height}px`

      // calculate amount to translate canvas to be in position
      const leftToRight = path.start.x <= path.end.x
      const translateX =
        (leftToRight ? path.start.x : path.end.x) - radius - lineWidth
      const translateY = path.start.y - radius - lineWidth

      canvas.style.transform = `translate(${translateX}px, ${translateY}px)`

      // draw the path to the canvas
      const drawOptions = defaultDrawPathOptions()
      drawOptions.scale = devicePixelRatio

      const normalizedPath = normalizePathToCanvasSize(path, width, height)
      requestAnimationFrame(() => {
        drawPath(normalizedPath, ctx, drawOptions)
      })
    }

    const { from, to } = connection
    addDrawHandler(drawSelf, from, to)
    return () => {
      removeDrawHandler(drawSelf, from, to)
    }
  }, [connection, canvasRef, webpageSize])

  const existsActivePaths = activeConcepts.size > 0
  const isInactive =
    existsActivePaths &&
    !(activeConcepts.has(connection.from) && activeConcepts.has(connection.to))

  const classNames = ['canvas']
  if (isInactive) {
    classNames.push('inactive')
  }

  return (
    <canvas
      ref={canvasRef}
      className={classNames.join(' ')}
      data-from={connection.from}
      data-to={connection.to}
    />
  )
}

function connectionToKey({ from, to }: ConceptConnection): string {
  return `path-${from}-${to}`
}
