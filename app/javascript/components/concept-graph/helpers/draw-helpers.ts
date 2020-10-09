import {
  ConceptPath,
  ConceptPathState,
  ConceptPathCoordinate,
} from '../concept-connection-types'

type DrawPathOptions = {
  scale: number
  dim: boolean
}

// Factory function for DrawPathOptions
export function defaultDrawPathOptions(): DrawPathOptions {
  return {
    scale: 1,
    dim: false,
  }
}

export function drawPath(
  path: ConceptPath,
  ctx: CanvasRenderingContext2D,
  options: DrawPathOptions
): void {
  path = scalePath(path, options.scale)
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
  const scale = options.scale

  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const lineWidth = Number(
    rootStyle.getPropertyValue('--c-concept-graph-line-width')
  )
  const dashedLine = [5, 7].map((v) => v * scale)
  const solidLine = [1, 0].map((v) => v * scale)

  switch (pathState) {
    case ConceptPathState.Available:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-available'
      )
      ctx.setLineDash(dashedLine)
      ctx.lineWidth = lineWidth * scale
      break

    case ConceptPathState.Completed:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-complete'
      )
      ctx.setLineDash(solidLine)
      ctx.lineWidth = lineWidth * scale
      break

    // ConceptPathState.Locked
    default:
      ctx.strokeStyle = rootStyle.getPropertyValue(
        '--c-concept-graph-line-locked'
      )
      ctx.setLineDash(dashedLine)
      ctx.lineWidth = lineWidth * scale
      break
  }
}

function defineCircle(
  ctx: CanvasRenderingContext2D,
  pos: ConceptPathCoordinate,
  pathState: ConceptPathState,
  options: DrawPathOptions
): void {
  const scale = options.scale
  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const radius = Number(
    rootStyle.getPropertyValue('--c-concept-graph-circle-radius')
  )

  ctx.arc(pos.x, pos.y, radius * scale, 0, 2 * Math.PI)
}

function applyCircleStyle(
  ctx: CanvasRenderingContext2D,
  pathState: ConceptPathState,
  options: DrawPathOptions
): void {
  const scale = options.scale
  // Use :root defined CSS variable values to style the path
  const rootStyle = getComputedStyle(document.documentElement)
  const lineWidth =
    Number(rootStyle.getPropertyValue('--c-concept-graph-line-width')) * scale
  const fillColor = rootStyle.getPropertyValue('--c-concept-graph-background')
  const solidLine = [1, 0].map((v) => v * scale)

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

function scalePath(path: ConceptPath, scale: number = 1): ConceptPath {
  return {
    start: {
      x: path.start.x * scale,
      y: path.start.y * scale,
    },
    end: {
      x: path.end.x * scale,
      y: path.end.y * scale,
    },
    state: path.state,
  }
}
