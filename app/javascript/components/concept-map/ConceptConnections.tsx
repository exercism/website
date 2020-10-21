import React, { useEffect, useRef, useState } from 'react'

import { useWebpageSize } from './hooks/useWebpageSize'

import { ConceptConnection } from './concept-connection-types'

import { defaultDrawPathOptions, drawPath } from './helpers/draw-helpers'
import { mapToPaths } from './helpers/path-helpers'

/**
 * ConceptConnections
 * This react component manages an HTML5 canvas to draw connections between concepts
 */
export const ConceptConnections = ({
  connections,
  activeConcepts,
}: {
  connections: ConceptConnection[]
  activeConcepts: Set<string>
}) => {
  const { width: webpageWidth, height: webpageHeight } = useWebpageSize()
  const paths = mapToPaths(connections)
  const pathCanvases = new Map(
    connections.map((connection) => [connectionToKey(connection), useRef(null)])
  )

  console.info(paths.length === connections.length)
  console.info({ paths, connections })

  useEffect(() => {
    connections.forEach((connection, i) => {
      const canvasRef = pathCanvases.get(connectionToKey(connection))

      if (!canvasRef) {
        return
      }

      const canvas = canvasRef.current as HTMLCanvasElement | null
      const ctx = canvas?.getContext('2d')

      if (!canvas || !ctx) return

      const width =
        webpageWidth -
        Number(canvas.style.borderLeftWidth) -
        Number(canvas.style.borderRightWidth) -
        2 // to account for vertical scroll bar

      const height =
        webpageHeight -
        Number(canvas.style.borderTopWidth) -
        Number(canvas.style.borderBottomWidth)

      canvas.width = width * devicePixelRatio
      canvas.height = height * devicePixelRatio

      canvas.style.width = `${width}px`
      canvas.style.height = `${height}px`

      const paths = mapToPaths(connections)

      const drawOptions = defaultDrawPathOptions()

      drawOptions.scale = devicePixelRatio
      drawPath(paths[i], ctx, drawOptions)
    })
  }, [connections, webpageHeight, webpageWidth])

  const hasActivePaths = activeConcepts.size > 0
  return (
    <>
      {connections.map((connection, i) => {
        const key = connectionToKey(connection)
        const isInactive =
          hasActivePaths &&
          !(
            activeConcepts.has(connection.from) &&
            activeConcepts.has(connection.to)
          )
        const classNames = ['canvas']
        if (isInactive) {
          classNames.push('inactive')
        }

        return (
          <canvas
            key={key}
            ref={pathCanvases.get(key)}
            className={classNames.join(' ')}
          />
        )
      })}
    </>
  )
}

function connectionToKey({ from, to }: ConceptConnection): string {
  return `path-${from}-${to}`
}
