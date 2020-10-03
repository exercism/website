import React, { useEffect, useRef } from 'react'

import { useWebpageSize } from './hooks/useWebpageSize'
import { slugToId } from './Exercise'
import { ExerciseState, ExerciseConnection } from './exercise-types'

enum ExercisePathState {
  Unavailable = 'unavailable',
  Available = 'available',
  Completed = 'completed',
}

type ExercisePathCoordinate = {
  x: number
  y: number
}

type ExercisePath = {
  start: ExercisePathCoordinate
  end: ExercisePathCoordinate
  state: ExercisePathState
}

type CategorizedExercisePaths = {
  unavailable: ExercisePath[]
  available: ExercisePath[]
  completed: ExercisePath[]
}

type DrawPathOptions = {
  dim: boolean
}

/**
 * ExerciseConnections
 * This react component manages an HTML5 canvas to draw connections between exercises
 */
export const ExerciseConnections = ({
  connections,
  activeExercise,
}: {
  connections: ExerciseConnection[]
  activeExercise: string | null
}) => {
  const { width: webpageWidth, height: webpageHeight } = useWebpageSize()
  const canvasEl = useRef(null)

  useEffect(() => {
    console.log({ webpageWidth, webpageHeight })

    // eslint-disable-next-line
    // const dpi = window.devicePixelRatio
    const canvas = canvasEl.current as HTMLCanvasElement | null
    const ctx = canvas?.getContext('2d')

    if (!canvas || !ctx) return

    const {
      unavailable: inactiveUnavailablePaths,
      available: inactiveAvailablePaths,
      completed: inactiveCompletedPaths,
    } = determinePathTypes(connections, activeExercise, false)

    const {
      unavailable: activeUnavailablePaths,
      available: activeAvailablePaths,
      completed: activeCompletedPaths,
    } = determinePathTypes(connections, activeExercise, true)

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
  }, [activeExercise, connections, webpageHeight, webpageWidth])

  return <canvas ref={canvasEl} className="canvas"></canvas>
}

function determinePathTypes(
  connections: ExerciseConnection[],
  activeExercise: string | null = null,
  matchActive: boolean | null = null
): CategorizedExercisePaths {
  const paths: CategorizedExercisePaths = {
    unavailable: [],
    available: [],
    completed: [],
  }

  connections.forEach(({ from, to }) => {
    // If looking to match only active paths, and if both ends of the path
    // don't connect to the active Exercise, then skip
    if (
      matchActive === true &&
      to !== activeExercise &&
      from !== activeExercise
    ) {
      return
    }

    // If looking to match only inactive edges, and if either end of the path
    // connect to the active Exercise, then skip
    if (
      matchActive === false &&
      (to === activeExercise || from === activeExercise)
    ) {
      return
    }

    // If the start or end exercise doesn't exist for some reason, skip
    const pathEndElement = document.getElementById(slugToId(to))
    if (!pathEndElement) {
      return
    }
    const pathStartElement = document.getElementById(slugToId(from))
    if (!pathStartElement) {
      return
    }

    const exerciseStatus = pathEndElement.dataset
      .exerciseStatus as ExerciseState
    const exercisePath = {
      start: getPathStartFromElement(pathStartElement),
      end: getPathEndFromElement(pathEndElement),
      state: getPathState(exerciseStatus),
    }

    switch (exercisePath.state) {
      case ExercisePathState.Available:
        paths.available.push(exercisePath)
        break
      case ExercisePathState.Completed:
        paths.completed.push(exercisePath)
        break
      default:
        paths.unavailable.push(exercisePath)
        break
    }
  })

  return paths
}

// calculate the start position of the path
//
// TODO: When this component becomes a sub-component, need to calculate the relative offset
// as the current is the position from the client window, where it will need to be the current
// relative to the canvas
//
// Do something like:
//   x = Math.floor(el.offsetLeft + el.offsetWidth / 2 - <CANVAS_ELEMENT>.offsetLeft) + 0.5
//   y = Math.ceil(el.offsetTop + el.offsetHeight - <CANVAS_ELEMENT>.offsetTop)
function getPathStartFromElement(el: HTMLElement): ExercisePathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2) + 0.5
  const y = Math.ceil(el.offsetTop + el.offsetHeight)

  return { x, y }
}

// calculate the end position of the path
//
// TODO: When this component becomes a sub-component, need to calculate the relative offset
// as the current is the position from the client window, where it will need to be the current
// relative to the canvas
//
// Do something like:
//   x = Math.floor(el.offsetLeft + el.offsetWidth / 2 - <CANVAS_ELEMENT>.offsetLeft) + 0.5
//   y = Math.floor(el.offsetTop - <CANVAS_ELEMENT>.offsetTop)
function getPathEndFromElement(el: HTMLElement): ExercisePathCoordinate {
  const x = Math.floor(el.offsetLeft + el.offsetWidth / 2) + 0.5
  const y = Math.floor(el.offsetTop)

  return { x, y }
}

// Derive the path state from the exercise state
function getPathState(exerciseStatus: ExerciseState): ExercisePathState {
  if (
    exerciseStatus === ExerciseState.Unlocked ||
    exerciseStatus === ExerciseState.InProgress
  ) {
    return ExercisePathState.Available
  } else if (exerciseStatus === ExerciseState.Completed) {
    return ExercisePathState.Completed
  }

  return ExercisePathState.Unavailable
}

// Factory function for DrawPathOptions
function defaultDrawPathOptions(): DrawPathOptions {
  return {
    dim: false,
  }
}

function drawPath(
  path: ExercisePath,
  ctx: CanvasRenderingContext2D,
  options: DrawPathOptions
): void {
  const { start, end } = path

  const pageWidth = document.documentElement.clientWidth
  const normalize =
    ((end.y - start.y) * Math.abs(start.x - end.x)) / (pageWidth / 2)
  const adjust = 6

  if (options.dim) {
    ctx.globalAlpha = 0.5
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
  pathState: ExercisePathState,
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
    case ExercisePathState.Available:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-available'
      )
      ctx.setLineDash(dashedLine)
      ctx.lineWidth = lineWidth
      break

    case ExercisePathState.Completed:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-complete'
      )
      ctx.setLineDash(solidLine)
      ctx.lineWidth = lineWidth
      break

    // ExercisePathState.Locked
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
  pos: ExercisePathCoordinate,
  pathState: ExercisePathState,
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
  pathState: ExercisePathState,
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
    case ExercisePathState.Available:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-available'
      )
      ctx.setLineDash(solidLine)
      ctx.fillStyle = fillColor
      ctx.lineWidth = lineWidth
      break

    case ExercisePathState.Completed:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-complete'
      )
      ctx.setLineDash(solidLine)
      ctx.fillStyle = fillColor
      ctx.lineWidth = lineWidth
      break

    // ExercisePathState.Locked
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
