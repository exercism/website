import React, { useEffect, useState } from 'react'
import { ChartConfiguration, ChartData } from 'chart.js'
import { Chart } from 'chart.js'

const FILL_COLOR = function (context) {
  const chart = context.chart
  const { ctx, chartArea } = chart

  if (!chartArea) {
    // This case happens on initial chart load
    return
  }
  return getGradient(ctx, chartArea)
}

function getGradient(ctx, chartArea) {
  let width, height, gradient
  const chartWidth = chartArea.right - chartArea.left
  const chartHeight = chartArea.bottom - chartArea.top
  if (!gradient || width !== chartWidth || height !== chartHeight) {
    // Create the gradient because this is either the first render
    // or the size of the chart has changed
    width = chartWidth
    height = chartHeight
    gradient = ctx.createLinearGradient(0, chartArea.bottom, 0, chartArea.top)
    gradient.addColorStop(0, '#604FCD')
    gradient.addColorStop(0.5, '#6F29C8')
  }

  return gradient
}

const GRID_COLOR = '#3c364a'

const CANVAS_BACKGROUND = {
  id: 'custom_canvas_background_color',
  beforeDraw: (chart) => {
    const { ctx } = chart
    ctx.save()
    ctx.globalCompositeOperation = 'destination-over'
    ctx.fillStyle = '#221E31'
    ctx.fillRect(0, 0, chart.width, chart.height)
    ctx.restore()
  },
}

const data = [65, 59, 80, 56, 45, 30].sort((a, b) => a - b)
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

const CONFIG: ChartConfiguration<'line'> = {
  type: 'line',
  data: DATA,

  options: {
    animation: false,
    borderColor: GRID_COLOR,
    responsive: true,
    scales: {
      x: {
        grid: {
          color: GRID_COLOR,
        },
      },
      y: {
        grid: {
          color: GRID_COLOR,
        },
      },
    },
    elements: {
      point: {
        radius: 0,
      },
    },

    plugins: {},
  },
}

export default function ImpactChart({ data }: { data: any }): JSX.Element {
  const [canvas, setCanvas] = useState<HTMLCanvasElement | null>(null)
  const [chart, setChart] = useState<Chart<'line'> | null>(null)
  useEffect(() => {
    if (!canvas) {
      return
    }
    const chart = new Chart<'line'>(canvas, CONFIG)

    setChart(chart)

    return () => chart.destroy()
  }, [canvas])

  useEffect(() => {
    if (!chart) {
      return
    }
    Chart.register(CANVAS_BACKGROUND)

    chart.data.labels = DATA.labels
    chart.data.datasets = DATA.datasets

    chart.update()
  }, [chart, DATA])

  return (
    <div>
      <canvas ref={setCanvas} />
    </div>
  )
}
