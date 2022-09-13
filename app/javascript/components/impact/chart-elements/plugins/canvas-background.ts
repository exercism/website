import { Chart } from 'chart.js'

const CANVAS_BACKGROUND_COLOR = '#221E31'

export const CANVAS_BACKGROUND = {
  id: 'custom_canvas_background_color',
  beforeDraw: (chart: Chart<'line'>): void => {
    const ctx: CanvasRenderingContext2D = chart.ctx
    ctx.save()
    ctx.globalCompositeOperation = 'destination-over'
    ctx.fillStyle = CANVAS_BACKGROUND_COLOR
    ctx.fillRect(0, 0, chart.width, chart.height)
    ctx.restore()
  },
}
