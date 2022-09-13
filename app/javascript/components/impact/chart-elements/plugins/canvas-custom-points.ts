import { Chart } from 'chart.js'

const POINT_BACKGROUND_COLOR = '#FFD38F'
const TOOLTIP_BACKGROUND_COLOR = '#302B42'

export const CANVAS_CUSTOM_POINTS = {
  id: 'custom_canvas_points',
  afterDraw: (chart: Chart<'line'>): void => {
    const ctx: CanvasRenderingContext2D = chart.ctx
    // 0 = index of our dataset, since we only draw one line, this is 0
    const points = chart.getDatasetMeta(0).data
    const { labels } = chart.config.data
    const milestones = chart.config._config.milestones
    console.log('milestones:', milestones)
    const radius = 32
    const fontSize = 40
    const tooltipBotMargin = 16
    const borderRadius = 8

    for (const milestone of milestones) {
      const index = labels!.findIndex((e) => e === milestone.date)
      const { x, y } = points[index]
      const customTooltipOptions: CustomTooltipOptions = {
        x,
        y: y - radius,
        font: '600 18px Poppins',
        radius: borderRadius,
        fillColor: TOOLTIP_BACKGROUND_COLOR,
        text: milestone.text,
        bottomMargin: tooltipBotMargin,
        lineHeight: 160,
        paddingX: 12,
        paddingY: 6,
      }
      drawCustomTooltip(ctx, customTooltipOptions)
      drawCircleWithEmoji(ctx, x, y, radius, fontSize, milestone.emoji)
    }
  },
}

function drawCircleWithEmoji(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  radius: number,
  fontSize: number,
  emoji: string
) {
  ctx.beginPath()
  ctx.arc(x, y, radius, 0, 2 * Math.PI, false)
  ctx.fillStyle = POINT_BACKGROUND_COLOR
  setShadow(ctx, '#0F0923', 0, 2, 4)
  ctx.fill()
  // clear it up, so won't be applied to emoji
  clearShadow(ctx)
  ctx.font = `${fontSize}px Arial`
  ctx.textAlign = 'center'
  ctx.textBaseline = 'alphabetic'
  ctx.strokeText(emoji, x, y + radius / 2)
  ctx.closePath()
}

function clearShadow(ctx: CanvasRenderingContext2D) {
  // initially the shadowColor is set to transparent black
  ctx.shadowColor = 'rgba(0, 0, 0, 0)'
  ctx.shadowOffsetX = 0
  ctx.shadowOffsetY = 0
  ctx.shadowBlur = 0
}

function setShadow(
  ctx: CanvasRenderingContext2D,
  color: string,
  offsetX: number,
  offsetY: number,
  blur: number
) {
  ctx.shadowColor = color
  ctx.shadowOffsetX = offsetX
  ctx.shadowOffsetY = offsetY
  ctx.shadowBlur = blur
}

type CustomTooltipOptions = {
  x: number
  y: number
  paddingX?: number
  paddingY?: number
  lineHeight?: number
  radius: number
  fill?: boolean
  fillColor?: string | CanvasPattern | CanvasGradient
  stroke?: boolean
  text: string
  font: string
  bottomMargin: number
}

function drawCustomTooltip(
  ctx: CanvasRenderingContext2D,
  options: CustomTooltipOptions
) {
  const {
    x: rawX,
    y: rawY,
    paddingX = 0,
    paddingY = 0,
    lineHeight = 100,
    bottomMargin,
    radius,
    fillColor = 'black',
    text,
    font,
  } = options

  ctx.beginPath()

  ctx.font = font
  const metrics = ctx.measureText(text)
  const rawWidth =
    Math.abs(metrics.actualBoundingBoxLeft) +
    Math.abs(metrics.actualBoundingBoxRight)
  const rawHeight =
    Math.abs(metrics.actualBoundingBoxAscent) +
    Math.abs(metrics.actualBoundingBoxDescent)

  const heightWithLineHeight = rawHeight * (Math.max(lineHeight, 100) / 100)
  const yOffsetCausedByLineHeight = (heightWithLineHeight - rawHeight) / 2

  const width = rawWidth + paddingX * 2
  const height = heightWithLineHeight + paddingY * 2
  // for now this will be always centered
  const x = rawX - width / 2
  const y = rawY - height - bottomMargin

  // draw a box with borderRadius
  ctx.moveTo(x + radius, y)
  ctx.lineTo(x + width - radius, y)
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
  ctx.lineTo(x + width, y + height - radius)
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
  ctx.lineTo(x + radius, y + height)
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
  ctx.lineTo(x, y + radius)
  ctx.quadraticCurveTo(x, y, x + radius, y)
  ctx.fillStyle = fillColor
  ctx.fill()

  // draw lil triangle
  const center = x + width / 2
  const bottom = y + height
  ctx.moveTo(center, bottom + 10)
  ctx.lineTo(center - 10, bottom)
  ctx.lineTo(center + 10, bottom)
  ctx.fillStyle = fillColor
  ctx.fill()

  // text
  ctx.fillStyle = 'white'
  ctx.textBaseline = 'top'
  ctx.textAlign = 'left'
  ctx.fillText(text, x + paddingX, y + yOffsetCausedByLineHeight + paddingY)
  ctx.closePath()
}
