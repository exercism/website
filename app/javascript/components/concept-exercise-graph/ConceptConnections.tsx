import React, { useEffect, useRef } from 'react'

import { useWebpageSize } from './hooks/useWebpageSize'

import { ConceptConnection } from './concept-connection-types'

import { defaultDrawPathOptions, drawPath } from './helpers/draw-helpers'
import { determinePathTypes } from './helpers/path-helpers'

/**
 * ConceptConnections
 * This react component manages an HTML5 canvas to draw connections between concepts
 */
export const ConceptConnections = ({
  connections,
  activeConcept,
}: {
  connections: ConceptConnection[]
  activeConcept: string | null
}) => {
  const { width: webpageWidth, height: webpageHeight } = useWebpageSize()
  const canvasEl = useRef(null)

  useEffect(() => {
    const canvas = canvasEl.current as HTMLCanvasElement | null
    const ctx = canvas?.getContext('2d')

    if (!canvas || !ctx) return

    const {
      unavailable: inactiveUnavailablePaths,
      available: inactiveAvailablePaths,
      completed: inactiveCompletedPaths,
    } = determinePathTypes(connections, activeConcept, false)

    const {
      unavailable: activeUnavailablePaths,
      available: activeAvailablePaths,
      completed: activeCompletedPaths,
    } = determinePathTypes(connections, activeConcept, true)

    // Determine the order drawn since canvas is drawn in bitmap
    // mode which means, things drawn first are covered up by
    // things drawn second if they overlap
    const inactiveDrawOrder = [
      inactiveUnavailablePaths,
      inactiveAvailablePaths,
      inactiveCompletedPaths,
    ]
    const activeDrawOrder = [
      activeUnavailablePaths,
      activeAvailablePaths,
      activeCompletedPaths,
    ]

    if (!canvas || !ctx) return

    canvas.height =
      webpageHeight -
      Number(canvas.style.borderTopWidth) -
      Number(canvas.style.borderBottomWidth)

    // Not sure why it needs two more pixel in chrome to account
    // for the width of the vertical scroll bar
    canvas.width =
      webpageWidth -
      Number(canvas.style.borderLeftWidth) -
      Number(canvas.style.borderRightWidth) -
      2 // See above

    const drawOptions = defaultDrawPathOptions()

    drawOptions.dim = Boolean(
      activeUnavailablePaths.length ||
        activeAvailablePaths.length ||
        activeCompletedPaths.length
    )
    inactiveDrawOrder.forEach((pathGroup) =>
      pathGroup.forEach((path) => drawPath(path, ctx, drawOptions))
    )

    drawOptions.dim = false
    activeDrawOrder.forEach((pathGroup) =>
      pathGroup.forEach((path) => drawPath(path, ctx, drawOptions))
    )
  }, [activeConcept, connections, webpageHeight, webpageWidth])

  return <canvas ref={canvasEl} className="canvas"></canvas>
}
