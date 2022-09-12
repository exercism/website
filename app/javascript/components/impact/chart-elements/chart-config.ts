/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { ChartConfiguration, ChartData } from 'chart.js'

const GRID_COLOR = '#3c364a'
const POINT_BACKGROUND_COLOR = '#FFD38F'
const CANVAS_BACKGROUND_COLOR = '#221E31'
const TOOLTIP_BACKGROUND_COLOR = '#302B42'
// const BACKGROUND_GRADIENT_A = '#6F29C8' // purpleish - this is in figma css
const BACKGROUND_GRADIENT_B = '#604FCD' // blueish
const FIGMA_BACKGROUND_GRADIENT_A = '#7029c8' //'rgb(112, 41, 200)' // purpleish - this is color-picked from figma design
const data = [65, 59, 80, 96, 56, 45, 30, 15].sort((a, b) => a - b)
const Y_AXIS_OFFSET = 2
const Y_AXIS_MAX = data[data.length - 1] * Y_AXIS_OFFSET

const FILL_COLOR = function (context: any) {
  const chart = context.chart
  const { ctx, chartArea } = chart

  if (!chartArea) {
    // This case happens on initial chart load
    return
  }
  return getGradient(ctx, chartArea)
}

function getGradient(ctx: any, chartArea: any) {
  let width, height, gradient
  const chartWidth = chartArea.right - chartArea.left
  const chartHeight = chartArea.bottom - chartArea.top
  if (!gradient || width !== chartWidth || height !== chartHeight) {
    // Create the gradient because this is either the first render
    // or the size of the chart has changed
    width = chartWidth
    height = chartHeight
    gradient = ctx.createLinearGradient(
      0,
      chartArea.bottom,
      0,
      chartArea.top + chartArea.bottom / 3
    ) // xStart, yStart, xEnd, yEnd
    gradient.addColorStop(0, FIGMA_BACKGROUND_GRADIENT_A)
    gradient.addColorStop(1, BACKGROUND_GRADIENT_B)
  }

  return gradient
}

export const CANVAS_BACKGROUND = {
  id: 'custom_canvas_background_color',
  beforeDraw: (chart: any) => {
    const { ctx } = chart
    ctx.save()
    ctx.globalCompositeOperation = 'destination-over'
    ctx.fillStyle = CANVAS_BACKGROUND_COLOR
    ctx.fillRect(0, 0, chart.width, chart.height)
    ctx.restore()
  },
}

export const CANVAS_CUSTOM_POINTS = {
  id: 'custom_canvas_points',
  afterDraw: (chart: any) => {
    const { ctx } = chart
    // 0 - index of our dataset, since we only draw one line, this is 0
    const points = chart.getDatasetMeta(0).data
    console.log('POINTS:', points)
    const { x, y } = points[1]
    const radius = 32
    const fontSize = 40
    const topMargin = 20
    drawBoxWithBorderRadius(ctx, x, y + topMargin, 50, 30, 8)
    drawCircleWithEmoji(ctx, x, y, radius, fontSize, '🚀')
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
  ctx.fill()
  ctx.font = `${fontSize}px Arial`
  ctx.textAlign = 'center'
  // aww this is nice... _so centered_!
  ctx.textBaseline = 'alphabetic'
  ctx.strokeText(emoji, x, y + radius / 2)
}

const label_a = 'Launch of Exercism V3'
const label_b = 'We hit 1M students!'
const DATA: ChartData<'line'> = {
  labels: new Array(data.length).fill(''),
  datasets: [
    {
      label: '',
      data,
      borderColor: 'rgba(0,0,0,0)',
      backgroundColor: FILL_COLOR,
      tension: 0.3,
      fill: true,
    },
  ],
}

function drawBoxWithBorderRadius(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  radius = 5,
  fill = false,
  stroke = true
) {
  ctx.beginPath()
  ctx.moveTo(x + radius, y)
  ctx.lineTo(x + width - radius, y)
  ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
  ctx.lineTo(x + width, y + height - radius)
  ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
  ctx.lineTo(x + radius, y + height)
  ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
  ctx.lineTo(x, y + radius)
  ctx.quadraticCurveTo(x, y, x + radius, y)
  ctx.closePath()
  if (fill) {
    ctx.fill()
  }
  if (stroke) {
    ctx.stroke()
  }
}

export const CONFIG: ChartConfiguration<'line'> = {
  type: 'line',
  data: DATA,
  options: {
    animation: false,
    borderColor: GRID_COLOR,
    responsive: true,
    maintainAspectRatio: false,

    layout: {
      padding: -10,
    },
    scales: {
      x: {
        offset: false,
        ticks: {
          display: false,
        },
        grid: {
          color: GRID_COLOR,
          drawBorder: false,
          borderWidth: 0,
        },
      },
      y: {
        offset: false,
        max: Y_AXIS_MAX,
        ticks: {
          display: false,
        },
        grid: {
          display: true,
          color: GRID_COLOR,
          borderWidth: 0,
        },
        labels: [],
      },
    },
    elements: {
      point: {
        radius: 0,
      },
    },
    plugins: {
      tooltip: {
        position: 'average',
        displayColors: false,
        padding: 12,
        bodyAlign: 'center',
        caretPadding: 12,
        callbacks: {
          label: renderLabels,
          footer: () => '',
        },
        yAlign: 'bottom',
        backgroundColor: TOOLTIP_BACKGROUND_COLOR,

        bodyFont: {
          family: 'Poppins',
          size: 18,
          weight: '600',
          lineHeight: '153%',
        },
      },
      legend: {
        display: false,
      },

      title: {
        display: false,
      },
    },
  },
}

function renderLabels(ctx: any) {
  console.log(ctx)
  let label = ctx.label || ''
  switch (ctx.raw) {
    case 56:
      label = label_a
      break
    case 80:
      label = label_b
      break
  }
  return label
}
