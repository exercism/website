import React, { useEffect, useRef } from 'react'

import { useWebpageSize } from './hooks/useWebpageSize'
import { conceptSlugToId } from './Concept'
import { ConceptState, ConceptConnection } from './concept-types'

enum ConceptPathState {
  Unavailable = 'unavailable',
  Available = 'available',
  Completed = 'completed',
}

type ConceptPathCoordinate = {
  x: number
  y: number
}

type ConceptPath = {
  start: ConceptPathCoordinate
  end: ConceptPathCoordinate
  state: ConceptPathState
}

type CategorizedConceptPaths = {
  unavailable: ConceptPath[]
  available: ConceptPath[]
  completed: ConceptPath[]
}

type DrawPathOptions = {
  dim: boolean
}

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

function determinePathTypes(
  connections: ConceptConnection[],
  activeConcept: string | null = null,
  matchActive: boolean | null = null
): CategorizedConceptPaths {
  const paths: CategorizedConceptPaths = {
    unavailable: [],
    available: [],
    completed: [],
  }

  connections.forEach(({ from, to }) => {
    // If looking to match only active paths, and if both ends of the path
    // don't connect to the active Concept, then skip
    if (
      matchActive === true &&
      to !== activeConcept &&
      from !== activeConcept
    ) {
      return
    }

    // If looking to match only inactive edges, and if either end of the path
    // connect to the active Concept, then skip
    if (
      matchActive === false &&
      (to === activeConcept || from === activeConcept)
    ) {
      return
    }

    // If the start or end concept doesn't exist for some reason, skip
    const pathEndElement = document.getElementById(conceptSlugToId(to))
    if (!pathEndElement) {
      return
    }
    const pathStartElement = document.getElementById(conceptSlugToId(from))
    if (!pathStartElement) {
      return
    }

    const conceptStatus = pathEndElement.dataset.conceptStatus as ConceptState
    const conceptPath = {
      start: getPathStartFromElement(pathStartElement),
      end: getPathEndFromElement(pathEndElement),
      state: getPathState(conceptStatus),
    }

    switch (conceptPath.state) {
      case ConceptPathState.Available:
        paths.available.push(conceptPath)
        break
      case ConceptPathState.Completed:
        paths.completed.push(conceptPath)
        break
      default:
        paths.unavailable.push(conceptPath)
        break
    }
  })

  return paths
}

// calculate the start position of the path

function getPathStartFromElement(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2) + 0.5
  const y = Math.ceil(el.offsetTop + el.offsetHeight)

  return { x, y }
}

// calculate the end position of the path
function getPathEndFromElement(el: HTMLElement): ConceptPathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2) + 0.5
  const y = Math.floor(el.offsetTop)

  return { x, y }
}

// Derive the path state from the concept state
function getPathState(conceptStatus: ConceptState): ConceptPathState {
  switch (conceptStatus) {
    case ConceptState.Unlocked:
    case ConceptState.InProgress:
      return ConceptPathState.Available
    case ConceptState.Completed:
      return ConceptPathState.Completed
    default:
      return ConceptPathState.Unavailable
  }
}

// Factory function for DrawPathOptions
function defaultDrawPathOptions(): DrawPathOptions {
  return {
    dim: false,
  }
}

function drawPath(
  path: ConceptPath,
  ctx: CanvasRenderingContext2D,
  options: DrawPathOptions
): void {
  const { start, end } = path

  const pageWidth = document.documentElement.clientWidth
  const normalize =
    ((end.y - start.y) * Math.abs(start.x - end.x)) / (pageWidth / 2)
  const adjust = 6

  if (options.dim) {
    ctx.globalAlpha = Number(
      getComputedStyle(document.documentElement).getPropertyValue(
        '--c-concept-graph-hover-opacity'
      )
    )
  }

  // Draw Line
  ctx.beginPath()
  applyLineStyle(ctx, path.state, options)
  ctx.moveTo(start.x, start.y)
  ctx.bezierCurveTo(
    start.x,
    start.y + normalize + adjust,
    end.x,
    end.y - normalize - adjust,
    end.x,
    end.y
  )
  ctx.stroke()

  // Draw Start Dot
  ctx.beginPath()
  defineCircle(ctx, path.start, path.state, options)
  applyCircleStyle(ctx, path.state, options)
  ctx.fill()
  ctx.stroke()

  // Draw End Dot
  ctx.beginPath()
  defineCircle(ctx, path.end, path.state, options)
  applyCircleStyle(ctx, path.state, options)
  ctx.fill()
  ctx.stroke()

  ctx.globalAlpha = 1
}

function applyLineStyle(
  ctx: CanvasRenderingContext2D,
  pathState: ConceptPathState,
  options: DrawPathOptions
): void {
  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const lineWidth = Number(
    rootStyle.getPropertyValue('--c-concept-graph-line-width')
  )
  const dashedLine = [5, 7]
  const solidLine = [1, 0]

  switch (pathState) {
    case ConceptPathState.Available:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-available'
      )
      ctx.setLineDash(dashedLine)
      ctx.lineWidth = lineWidth
      break

    case ConceptPathState.Completed:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-complete'
      )
      ctx.setLineDash(solidLine)
      ctx.lineWidth = lineWidth
      break

    // ConceptPathState.Locked
    default:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-locked'
      )
      ctx.setLineDash(dashedLine)
      ctx.lineWidth = lineWidth
      break
  }
}

function defineCircle(
  ctx: CanvasRenderingContext2D,
  pos: ConceptPathCoordinate,
  pathState: ConceptPathState,
  options: DrawPathOptions
): void {
  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const radius = Number(
    rootStyle.getPropertyValue('--c-concept-graph-circle-radius')
  )

  ctx.arc(pos.x, pos.y, radius, 0, 2 * Math.PI)
}

function applyCircleStyle(
  ctx: CanvasRenderingContext2D,
  pathState: ConceptPathState,
  options: DrawPathOptions
): void {
  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const lineWidth = Number(
    rootStyle.getPropertyValue('--c-concept-graph-line-width')
  )
  const fillColor = rootStyle.getPropertyValue('--c-concept-graph-background')
  const solidLine = [1, 0]

  switch (pathState) {
    case ConceptPathState.Available:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-available'
      )
      ctx.setLineDash(solidLine)
      ctx.fillStyle = fillColor
      ctx.lineWidth = lineWidth
      break

    case ConceptPathState.Completed:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-complete'
      )
      ctx.setLineDash(solidLine)
      ctx.fillStyle = fillColor
      ctx.lineWidth = lineWidth
      break

    // ConceptPathState.Locked
    default:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-locked'
      )
      ctx.setLineDash(solidLine)
      ctx.fillStyle = fillColor
      ctx.lineWidth = lineWidth
      break
  }
}
