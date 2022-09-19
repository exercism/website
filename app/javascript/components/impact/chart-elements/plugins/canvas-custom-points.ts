import { Chart } from 'chart.js'

const POINT_BACKGROUND_COLOR = '#FFD38F'
const TOOLTIP_BACKGROUND_COLOR = '#302B42'
const TW_MD = 768

export const CANVAS_CUSTOM_POINTS = {
  id: 'custom_canvas_points',
  afterDraw: (chart: Chart<'line'>): void => {
    const ctx: CanvasRenderingContext2D = chart.ctx
    // 0 = index of our dataset, since we only draw one line, this is 0
    const points = chart.getDatasetMeta(0).data
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    // this is a meta key, so it isn't present on the type signature
    const { milestones, dateMap } = chart.config._config
    const radius = 32
    const fontSize = 32
    const borderRadius = 8

    for (const milestone of milestones) {
      if (dateMap[milestone.date]) {
        const { x, y } = points[dateMap[milestone.date]]
        const customTooltipOptions: CustomTooltipOptions = {
          x,
          y: y - radius,
          font: { weight: 600, size: 18, family: 'Poppins' },
          radius: borderRadius,
          fillColor: TOOLTIP_BACKGROUND_COLOR,
          text: milestone.text,
          bottomMargin: 12,
          lineHeight: 160,
          paddingX: 12,
          paddingY: 6,
          chartWidth: chart.width,
        }
        drawCircleWithEmoji(ctx, x, y, radius, fontSize, milestone.emoji)
        if (chart.width > TW_MD - 16) {
          drawCustomTooltip(ctx, customTooltipOptions)
        }
      } else continue
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
  // clean it up, so won't be applied to emoji
  cleanUpShadow(ctx)
  ctx.font = `${fontSize}px Arial`
  ctx.textAlign = 'center'
  ctx.textBaseline = 'alphabetic'
  ctx.strokeText(emoji, x, y + 12)
  ctx.closePath()
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

function cleanUpShadow(ctx: CanvasRenderingContext2D) {
  // initially the shadowColor is set to transparent black
  setShadow(ctx, 'rgba(0,0,0,0)', 0, 0, 0)
}

type TooltipFont = {
  size: number
  family: string
  weight: number
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
  font: TooltipFont
  bottomMargin: number
  chartWidth: number
}

function drawCustomTooltip(
  ctx: CanvasRenderingContext2D,
  options: CustomTooltipOptions
) {
  const {
    x: origoX,
    y: origoY,
    paddingX = 0,
    paddingY = 0,
    lineHeight = 100,
    bottomMargin = 0,
    radius = 0,
    fillColor = 'black',
    text = '',
    chartWidth,
    font = { weight: 500, size: 12, family: 'Arial' },
  } = options

  ctx.beginPath()

  ctx.font = `${font.weight} ${font.size}px ${font.family}`
  const metrics = ctx.measureText(text)
  const rawWidth =
    Math.abs(metrics.actualBoundingBoxLeft) +
    Math.abs(metrics.actualBoundingBoxRight)

  const tipHeight = 10
  const tipWidth = 10 //x2
  const lineHeightCent = lineHeight / 100
  const width = rawWidth + paddingX * 2
  const height = lineHeightCent * font.size + paddingY * 2

  // center tooltip
  const centeredX = origoX - width / 2

  // we need this, so the tip won't disattach itself from rect on screen width change
  const RESPONSIVE_MARGIN = Math.min(
    chartWidth - origoX - tipWidth,
    origoX - tipWidth
  )
  const MARGIN_X = Math.min(10, RESPONSIVE_MARGIN)

  // Make sure tooltip stays on screen on both ends
  const x = Math.max(
    MARGIN_X,
    centeredX - Math.max(0, centeredX + width - chartWidth + MARGIN_X)
  )
  const y = origoY - height - bottomMargin - tipHeight

  // triangle constants
  const bottom = y + height
  const tipTopLeft = origoX - tipWidth
  const tipTopRight = origoX + tipWidth
  const tipRightToRectEnd = x + width - tipTopRight
  const tipLeftToRectStart = tipTopLeft - x
  // adaptive border radius, that changes when tooltip is nearer to the end of rectangle
  const brBorderRadius = Math.min(radius, tipRightToRectEnd)
  const blBorderRadius = Math.min(radius, tipLeftToRectStart)

  // draw a rectangle with borderRadius
  ctx.moveTo(x + radius, y)
  ctx.lineTo(x + width - radius, y)
  // tr
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
  ctx.lineTo(x + width, y + height - radius)
  // br
  ctx.quadraticCurveTo(
    x + width,
    y + height,
    x + width - brBorderRadius,
    y + height
  )
  ctx.lineTo(x + radius, y + height)
  // bl
  ctx.quadraticCurveTo(x, y + height, x, y + height - blBorderRadius)
  ctx.lineTo(x, y + radius)
  // tl
  ctx.quadraticCurveTo(x, y, x + radius, y)
  ctx.fillStyle = fillColor
  ctx.fill()

  // draw a lil triangle a.k.a. "tip" that points towards the origo of custom point
  ctx.moveTo(origoX, bottom + tipHeight)
  ctx.lineTo(tipTopLeft, bottom)
  ctx.lineTo(tipTopRight, bottom)
  ctx.fillStyle = fillColor
  ctx.fill()

  // text
  ctx.fillStyle = 'white'
  ctx.textBaseline = 'alphabetic'
  ctx.textAlign = 'left'
  ctx.fillText(text, x + paddingX, y + height / 2 + paddingY)
  ctx.closePath()
}
