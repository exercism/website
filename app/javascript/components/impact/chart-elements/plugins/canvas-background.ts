import { Chart } from 'chart.js'

const CANVAS_BACKGROUND_COLOR = '#221E31'
export const GRID_COLOR = '#3c364a'

export const CANVAS_BACKGROUND = {
  id: 'custom_canvas_background_color',
  beforeDraw: (chart: Chart<'line'>): void => {
    const ctx: CanvasRenderingContext2D = chart.ctx
    ctx.save()
    ctx.globalCompositeOperation = 'destination-over'
    drawGrid(chart)
    ctx.fillStyle = CANVAS_BACKGROUND_COLOR
    ctx.fillRect(0, 0, chart.width, chart.height)
    ctx.restore()
  },
}

function drawGrid(chart: Chart<'line'>) {
  const ctx = chart.ctx
  const height = chart.height,
    width = chart.width,
    squareSide = 150
  for (let x = 0; x < width; x += squareSide) {
    ctx.moveTo(x, 0)
    ctx.lineTo(x, height)
  }
  for (let y = 0; y < height; y += squareSide) {
    ctx.moveTo(0, y)
    ctx.lineTo(width, y)
  }
  ctx.strokeStyle = GRID_COLOR
  ctx.lineWidth = 1
  ctx.stroke()
}
