import { ChartConfiguration, ChartData } from 'chart.js'

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
    gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top)
    gradient.addColorStop(0, '#6F29C8')
    gradient.addColorStop(0.4, '#604FCD')
  }

  return gradient
}

const GRID_COLOR = '#3c364a'

export const CANVAS_BACKGROUND = {
  id: 'custom_canvas_background_color',
  beforeDraw: (chart: any) => {
    const { ctx } = chart
    ctx.save()
    ctx.globalCompositeOperation = 'destination-over'
    ctx.fillStyle = '#221E31'
    ctx.fillRect(0, 0, chart.width, chart.height)
    ctx.restore()
  },
}

const data = [65, 59, 80, 96, 56, 45, 30, 15].sort((a, b) => a - b)
const Y_AXIS_MAX = data[data.length - 1] * 2
const DATA: ChartData<'line'> = {
  labels: new Array(data.length).fill(' '),
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

export const CONFIG: ChartConfiguration<'line'> = {
  type: 'line',
  data: DATA,

  options: {
    animation: false,
    borderColor: GRID_COLOR,
    responsive: true,
    maintainAspectRatio: true,
    aspectRatio: 3 / 2,
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
      legend: {
        display: false,
      },
      title: {
        display: false,
      },
    },
  },
}
